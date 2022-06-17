function [output] = Morpho_MultiANN(pathDB, extension, dimensions,  type, option, dirOut, ColorType, filtro, stopSpace, stopOption)
      
 for l = 1:size(dimensions,2)
       nPCA = dimensions(l);
       neurons = 3:1:40;
       %neurons = [neurons,nPCA:1:(nPCA + 13)];
       %neurons = 5:1:(nPCA + 13);
       
       Morpho_ANN(pathDB, extension, type, option, nPCA, neurons, dirOut, ColorType, filtro, stopSpace, stopOption);
  end

  output = 1;
end
