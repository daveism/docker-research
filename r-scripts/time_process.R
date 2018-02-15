time_process <- function(func, proc_name, args, is.logged=TRUE) {
  
  if (is.logged == TRUE) {
    print('BEGIN TIMING PROCESS:')
    print(paste(' - NAME:', proc_name))
    print(paste(' - ARGS:', paste(args, collapse=', '), collapse=''))
  }
  
  # Time the function
  t0 <- proc.time()
  val <- do.call(func, args)
  t1 <- sprintf('%03.2f', (proc.time()-t0)[3]/60^1)
  
  if (is.logged == TRUE) {
    print(paste('TIME ELAPSED:', t1, 'min'))
  }
  
  return(t1)
}
