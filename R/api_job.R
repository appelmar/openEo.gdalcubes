# job handlers

.listAllJobs = function() {
  jobs = list(jobs = unname(lapply(Session$jobs, function(job){
      return(job$jobInfo())
    })))

    links = list(
      rel = "self",
      href = paste(Session$getBaseUrl(), "jobs", sep = "/")
    )

    result = as.vector(c(jobs, links =list(list(links))))

    return(result)
  }

.getJobById = function(req, res, job_id) {
  index = getJobIdIndex(job_id)

  if (! is.na(index)) {
    job = Session$jobs[[index]]

    res$body = jsonlite::toJSON(job$jobInfo(),na="null",null="null",auto_unbox = TRUE)
    res$setHeader("Content-Type","application/json")
    res$status = 200

    return(res)
  }
  else {
    stop("Job not found")
  }
}

.createNewJob = function(req,res) {

    sent_job = jsonlite::fromJSON(req$rook.input$read_lines(),simplifyDataFrame = FALSE)

    process_graph = sent_job$process

    job = Job$new(process = process_graph)
    job$status = "created"
    job$created = as.character(Sys.time())

    if (!is.null(sent_job$title)) { job$title = sent_job$title }
    if (!is.null(sent_job$description)) { job$description = sent_job$description }

    writeJobInfo(job)

    Session$assignJob(job)

    res$setHeader(name = "Location",
                  value= paste(Session$getBaseUrl(), "jobs", job$id, sep ="/"))
    res$setHeader(name = "OpenEO-Identifier",value = job$id)
    res$status = 201

    return(res)
}

.startJob = function(req, res, job_id) {
  index = getJobIdIndex(job_id)

  if (! is.na(index)) {
    job = Session$jobs[[index]]

    Session$runJob(job = job)
    res$status = 202

    return(res)
  }
  else {
    res$status = 404
    list(error = "Job not found")
  }
}

.getJobResults = function(req, res, job_id) {
  index = getJobIdIndex(job_id)

  if (! is.na(index)) {
    job = Session$jobs[[index]]
    if (job$status != "finished") {
      res$status = 404
      list(error = "Job not finished")
    }
    else {
      job_results = paste(Session$getConfig()$workspace.path,"jobs",job_id,sep="/")
      base = paste0(Session$getBaseUrl(),"/","result/",job_id)
      links = paste("file:/",job_results,list.files(job_results),sep="/")
      files = list.files(job_results)

      assets = list()
      for (i in 1:length(files)) {

        apList = list(list(href = links[i]))
        names(apList) = files[i]
        assets = append(assets, apList)
      }

      return(list(
        title = job$title,
        description = job$description,
        assets = assets
      ))
    }
  }
  else {
    res$status = 404
    list(error = "Job not found")
  }
}