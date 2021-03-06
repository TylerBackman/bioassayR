trinarySimilarity <- function(queryMatrix, targetMatrix, minSharedScreenedTargets = 12, minSharedActiveTargets = 3){
    if(class(queryMatrix) != "dgCMatrix")
        stop("'queryMatrix' not of class 'dgCMatrix' as created by perTargetMatrix, if subsetting use drop=F")
    if(class(targetMatrix) != "dgCMatrix")
        stop("'targetMatrix' not of class 'dgCMatrix' as created by perTargetMatrix")
    if(ncol(queryMatrix) > 1)
        stop("'queryMatrix' has more than one column (compound)- subset first i.e. queryMatrix[,1,drop=F]")
    if(class(minSharedScreenedTargets) != "numeric")
        stop("'minSharedScreenedTargets' not of class 'numeric'")
    if(class(minSharedActiveTargets) != "numeric")
        stop("'minSharedActiveTargets' not of class 'numeric'")
    
    queryActives <- row.names(queryMatrix)[queryMatrix@i[queryMatrix@x == 2] + 1]
    queryInactives <- row.names(queryMatrix)[queryMatrix@i[queryMatrix@x == 1] + 1]    
    tMatrix <- as(targetMatrix, "TsparseMatrix")
    
    scores <- tapply(1:length(tMatrix@i), tMatrix@j, function(x){
        # x <- (1:length(tMatrix@i))[tMatrix@j == 0] # test code
        targetList <- tMatrix@i[x]
        targetScores <- tMatrix@x[x]
        targetActives <- row.names(tMatrix)[targetList[targetScores == 2] + 1]
        targetInactives <- row.names(tMatrix)[targetList[targetScores == 1] + 1]    
        intersectSize <- length(intersect(queryActives, targetActives))
        unionSize <- intersectSize + length(intersect(queryActives, targetInactives)) + length(intersect(targetActives, queryInactives))
        sharedScreenedTargets <- length(intersect(c(queryActives, queryInactives), c(targetActives, targetInactives)))
        if(intersectSize < minSharedActiveTargets && sharedScreenedTargets < minSharedScreenedTargets)
            return(NA)
        if(unionSize == 0)
            return(NA)
        return(intersectSize / unionSize)
    }, simplify = T)
    
    allScores <- rep(NA, ncol(targetMatrix))
    names(allScores) <- colnames(targetMatrix)
    allScores[as.numeric(names(scores)) + 1] <- as.numeric(scores)
    
    return(allScores)
}