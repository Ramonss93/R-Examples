spellTree_1 <-
  function(letra = character(), 
           bandera = integer(), 
           left = integer(), 
           rigth = integer(), 
           center = integer(),
           palabra = list()) {
    tree <- list(ch = letra, flag = bandera, L = left, R = rigth, C = center, word = palabra)
    class(tree) <- append(class(tree), "spellTree_1")
    return(tree)
  }
