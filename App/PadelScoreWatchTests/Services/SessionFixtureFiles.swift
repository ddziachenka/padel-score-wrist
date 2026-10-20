/// The saved files of `SessionFixtures`, exactly as schema version 1 writes them. They are
/// committed text rather than produced by the test, so the format cannot drift unnoticed.
enum SessionFixtureFiles {
    static let matchVersion1 = #"""
    {
      "schemaVersion" : 1,
      "session" : {
        "current" : {
          "game" : {
            "format" : {
              "match" : {
                "_0" : {
                  "completedSets" : [
                    {
                      "them" : 6,
                      "us" : 7
                    }
                  ],
                  "games" : {
                    "them" : 3,
                    "us" : 2
                  },
                  "phase" : {
                    "game" : {
                      "_0" : {
                        "advantage" : {
                          "_0" : "them"
                        }
                      }
                    }
                  },
                  "rules" : {
                    "deuceRule" : "advantage",
                    "setPolicy" : "tieBreakAtSixAll"
                  },
                  "service" : {
                    "isConfirmed" : true,
                    "order" : "youThenOpponent1",
                    "server" : "opponent1"
                  }
                }
              }
            },
            "id" : "00000000-0000-0000-0000-000000000011",
            "status" : "active"
          },
          "history" : [
            {
              "before" : {
                "format" : {
                  "match" : {
                    "_0" : {
                      "completedSets" : [
                        {
                          "them" : 6,
                          "us" : 7
                        }
                      ],
                      "games" : {
                        "them" : 3,
                        "us" : 2
                      },
                      "phase" : {
                        "game" : {
                          "_0" : {
                            "points" : {
                              "them" : "thirty",
                              "us" : "forty"
                            }
                          }
                        }
                      },
                      "rules" : {
                        "deuceRule" : "advantage",
                        "setPolicy" : "tieBreakAtSixAll"
                      },
                      "service" : {
                        "isConfirmed" : true,
                        "order" : "youThenOpponent1",
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000011",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000001",
              "revision" : 41
            },
            {
              "before" : {
                "format" : {
                  "match" : {
                    "_0" : {
                      "completedSets" : [
                        {
                          "them" : 6,
                          "us" : 7
                        }
                      ],
                      "games" : {
                        "them" : 3,
                        "us" : 2
                      },
                      "phase" : {
                        "game" : {
                          "_0" : {
                            "deuce" : {

                            }
                          }
                        }
                      },
                      "rules" : {
                        "deuceRule" : "advantage",
                        "setPolicy" : "tieBreakAtSixAll"
                      },
                      "service" : {
                        "isConfirmed" : true,
                        "order" : "youThenOpponent1",
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000011",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000002",
              "revision" : 42
            }
          ]
        },
        "lastCommand" : "00000000-0000-0000-0001-000000000002",
        "previousResult" : {
          "format" : {
            "americano" : {
              "_0" : {
                "rules" : {
                  "ralliesPerServer" : 2,
                  "totalRallies" : 16
                },
                "score" : {
                  "them" : 7,
                  "us" : 9
                },
                "service" : {
                  "order" : "youThenOpponent1",
                  "rallyInBlock" : 1,
                  "server" : "you"
                }
              }
            }
          },
          "id" : "00000000-0000-0000-0000-000000000010",
          "status" : "finished"
        },
        "recentSettings" : {
          "americano" : {
            "ralliesPerServer" : 2,
            "totalRallies" : 16
          },
          "match" : {
            "deuceRule" : "advantage",
            "setPolicy" : "tieBreakAtSixAll"
          },
          "serving" : {
            "firstServer" : "opponent1",
            "order" : "youThenOpponent1"
          }
        },
        "revision" : 42,
        "usage" : {
          "countedGames" : [
            "00000000-0000-0000-0000-000000000010",
            "00000000-0000-0000-0000-000000000011"
          ],
          "isExact" : true
        }
      }
    }
    """#

    static let americanoVersion1 = #"""
    {
      "notice" : "restoredFromBackup",
      "schemaVersion" : 1,
      "session" : {
        "current" : {
          "game" : {
            "format" : {
              "americano" : {
                "_0" : {
                  "rules" : {
                    "ralliesPerServer" : 2,
                    "totalRallies" : 4
                  },
                  "score" : {
                    "them" : 2,
                    "us" : 2
                  },
                  "service" : {
                    "order" : "youThenOpponent2",
                    "rallyInBlock" : 1,
                    "server" : "you"
                  }
                }
              }
            },
            "id" : "00000000-0000-0000-0000-000000000021",
            "status" : "finished"
          },
          "history" : [
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 0,
                        "us" : 0
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 1,
                        "server" : "partner"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000012",
              "revision" : 2
            },
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 0,
                        "us" : 1
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 2,
                        "server" : "partner"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000013",
              "revision" : 3
            },
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 1,
                        "us" : 1
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 1,
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000014",
              "revision" : 4
            },
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 1,
                        "us" : 2
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 2,
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "active"
              },
              "change" : "finish",
              "command" : "00000000-0000-0000-0001-000000000015",
              "revision" : 5
            },
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 1,
                        "us" : 2
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 2,
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "finished"
              },
              "change" : "resume",
              "command" : "00000000-0000-0000-0001-000000000016",
              "revision" : 6
            },
            {
              "before" : {
                "format" : {
                  "americano" : {
                    "_0" : {
                      "rules" : {
                        "ralliesPerServer" : 2,
                        "totalRallies" : 4
                      },
                      "score" : {
                        "them" : 1,
                        "us" : 2
                      },
                      "service" : {
                        "order" : "youThenOpponent2",
                        "rallyInBlock" : 2,
                        "server" : "opponent1"
                      }
                    }
                  }
                },
                "id" : "00000000-0000-0000-0000-000000000021",
                "status" : "active"
              },
              "change" : "point",
              "command" : "00000000-0000-0000-0001-000000000017",
              "revision" : 7
            }
          ]
        },
        "lastCommand" : "00000000-0000-0000-0001-000000000017",
        "recentSettings" : {
          "americano" : {
            "ralliesPerServer" : 2,
            "totalRallies" : 4
          },
          "serving" : {
            "firstServer" : "partner",
            "order" : "youThenOpponent2"
          }
        },
        "revision" : 7,
        "usage" : {
          "countedGames" : [
            "00000000-0000-0000-0000-000000000021"
          ],
          "isExact" : false
        }
      }
    }
    """#
}
