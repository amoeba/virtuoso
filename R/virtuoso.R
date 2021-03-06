

#' vos_import
#'
#' @param con a ODBC connection to Virtuoso, from [`vos_connect()`]
#' @param files paths to files to be imported
#' @param wd The directory from which we can search the files.
#' NOTE: This directory must match or be in the directory from which you ran vos_start().
#' This is the default behavior and probably best not altered.
#' @param ext glob and extension to match file types. Defaults to match any nquads.
#' @param graph Name (technically URI) for a graph in the database.  Can leave as default.
#'
#' @export
vos_import <- function(con, files, wd = ".", ext = "*.nq", graph = "rdflib"){
  ## We have to copy files into the directory Virtuoso can access.
  ## This is the directory where virtuoso.ini is located.

  ## Can we use file.symlink instead of copy?
  lapply(files, function(from) file.copy(from, file.path(wd, basename(from))))

  DBI::dbGetQuery(con, paste0("ld_dir('", wd, "', '", ext, "', '", graph, "')") )
  DBI::dbGetQuery(con, "rdf_loader_run()" )

  ## clean up
  unlink(file.path(wd, basename(files)))
}


#' Run SPARQL query
#'
#' @param query a SPARQL query statement
#' @inheritParams vos_import
#' @export
vos_query <- function(con, query, graph = "rdflib"){
  ## FIXME construct SQL query more nicely with existing parsers
  DBI::dbGetQuery(con, paste0("SPARQL ",  query))
}

#' Clear all triples from a graph
#'
#' @export
#' @inheritParams vos_import
vos_clear_graph <- function(con, graph = "rdflib"){
  DBI::dbGetQuery(con, paste0("SPARQL CLEAR GRAPH <", graph, ">"))

}

