function [output] = Morpho_MultiRegression(pathDB, extension, dimensions,  type, option, dirOut, ColorType, filtro, stopSpace, stopOption)
if (option ==1)
  for l = 1:size(dimensions,2)
       dimension = dimensions(l);
       finalDirDB = strcat(pathDB, num2str(dimension), '/');
        Morpho_Regression(finalDirDB, extension, type)
   end
elseif(option==2 || option==3)
    w = size(dimensions,2);
  for d = 1:w
       nPCA = dimensions(d);
       Morpho_Regression(pathDB, extension, type, option, nPCA, dirOut, ColorType, filtro, stopSpace, stopOption)
  end
end
output = 1;

end
