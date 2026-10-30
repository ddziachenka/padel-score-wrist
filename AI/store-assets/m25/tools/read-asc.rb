# Read-only ASC context. The private key is used only for signing; never serialized or logged.
require 'openssl'
require 'base64'
require 'json'
require 'net/http'
require 'uri'
require 'time'
require 'fileutils'
raise 'ASC credentials are not configured' unless %w[ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_PATH].all? { |name| ENV[name] && !ENV[name].empty? }
def b64(value) Base64.urlsafe_encode64(value, padding: false) end
header=b64(JSON.generate({alg:'ES256',kid:ENV.fetch('ASC_KEY_ID'),typ:'JWT'}))
now=Time.now.to_i
payload=b64(JSON.generate({iss:ENV.fetch('ASC_ISSUER_ID'),iat:now-30,exp:now+600,aud:'appstoreconnect-v1'}))
signed_input="#{header}.#{payload}"
key=OpenSSL::PKey.read(File.binread(ENV.fetch('ASC_KEY_PATH')))
asn=OpenSSL::ASN1.decode(key.dsa_sign_asn1(OpenSSL::Digest::SHA256.digest(signed_input)))
signature=asn.value.map { |integer| integer.value.to_i.to_s(16).rjust(64,'0') }.join
bearer="#{signed_input}.#{b64([signature].pack('H*'))}"
get=lambda do |path|
 uri=URI(path.start_with?('https://') ? path : 'https://api.appstoreconnect.apple.com'+path)
 raise 'Unexpected ASC host' unless uri.scheme=='https' && uri.host=='api.appstoreconnect.apple.com'
 request=Net::HTTP::Get.new(uri);request['Authorization']='Bearer '+bearer
 response=Net::HTTP.start(uri.host,uri.port,use_ssl:true,open_timeout:20,read_timeout:45) { |http| http.request(request) }
 raise "ASC GET status #{response.code}" unless response.code=='200'
 JSON.parse(response.body)
end
app=get.call('/v1/apps/6825393194')['data']
infos=get.call('/v1/apps/6825393194/appInfos')['data']
versions=get.call('/v1/apps/6825393194/appStoreVersions?limit=20')['data']
result={observed_at:Time.now.utc.iso8601,method:'GET only; no metadata, pricing, build or submission mutation',app:{id:app['id'],name:app['attributes']['name'],bundleId:app['attributes']['bundleId'],primaryLocale:app['attributes']['primaryLocale']},app_infos:[],versions:[]}
infos.each do |info|
 row={id:info['id'],state:info['attributes']['appStoreState'],primary_category:info.dig('relationships','primaryCategory','data','id'),secondary_category:info.dig('relationships','secondaryCategory','data','id')}
 ['primaryCategory','secondaryCategory'].each do |category|
  link=info.dig('relationships',category,'links','related')
  related_category=link ? get.call(link)['data'] : nil
  row[category=='primaryCategory' ? :primary_category : :secondary_category]=related_category && related_category['id']
 end
 related=info.dig('relationships','ageRatingDeclaration','links','related')
 row[:age_rating_declaration]=get.call(related)['data']['attributes'] if related
 result[:app_infos] << row
end
versions.each { |v| result[:versions] << {id:v['id'],version:v['attributes']['versionString'],platform:v['attributes']['platform'],state:v['attributes']['appStoreState'],build:v.dig('relationships','build','data','id')} }
out=File.expand_path('../../../evidence/M25/asc-readback.json',__dir__)
FileUtils.mkdir_p(File.dirname(out));File.write(out,JSON.pretty_generate(result)+"\n")
puts "ASC read-only context saved; #{infos.length} app-info records, #{versions.length} versions"
