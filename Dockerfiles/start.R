library(openEo.gdalcubes)

config = SessionConfig(api.port = 8000, host = "0.0.0.0")
config$workspace.path = "/var/openeo/workspace"
createSessionInstance(config)
Session$startSession()
