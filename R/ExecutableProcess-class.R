#' Executable process
#'
#' @include Process-class.R
#' @importFrom R6 R6Class
#'
#' @export
ExecutableProcess <- R6Class(
  "ExecutableProcess",
  inherit = Process,
  public = list(

    #' @description Initialize executable process
    #'
    #' @param id Id or name of the proces
    #' @param description Shortly what the process does
    #' @param parameters Used parameters in the process
    #' @param operation Function that executes the process
    #' @param process Processes which will be executed
    #'
    initialize= function(id = NA,
                        description = NA,
                        parameters = NA,
                        operation = NA,
                        process= NULL) {

          if (is.null(process)) {}

          else {
            variables = names(process)
            for (key in variables) {
              value = process[[key]]
              if (class(value) == "function" || class(value) == "environment") { #?
                next()
              } else {
                self[[key]] = value
              }
            }
          }
    },

    #' @description Run the operation including a generated list of parameters
    #'
    execute = function() {

        parameterList = list()
        for (key in 1:length(self$parameters)) {
          name = self$parameters[[key]]$name
          value = self$parameters[[key]]$value

          if (is.ExecutableProcess(value)) {
            parameterList[[name]] = value$execute()
          } else {
            parameterList[[name]] = value
          }

        }
        result = do.call(self$operation, parameterList, envir = self)

        return(result)
    }
  )
)

#' Check if given process is a process
#' @param obj Process to be checked
is.ExecutableProcess = function(obj) {
  return(all(c("ExecutableProcess", "Process") %in% class(obj)) )
}