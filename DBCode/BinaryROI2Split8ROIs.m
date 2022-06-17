function [M] = BinaryROI2Split8ROIs(MatrixBinary, NumSections)
% BinaryROI2Split8ROIs Function for to divide binary image of the Regions of interest of the landraces in 8 parts.
% MatrixBinary : Matrix or binary image of MxN
% rng('default')
% rng(0, "threefry")
% gpurng(0, "threefry")

if ~isnumeric(MatrixBinary)
    error('MyComponent:incorrectType',...
        'Error. \nEntrada debe ser tipo logical, y no del tipo %s.',class(MatrixBinary));
end
Mask = ~MatrixBinary;
% Clean up small groups pixels
[ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
s=find([propied.Area] < 1000); % grupos menores a 100 px
for i=1:size(s,2)              % eliminaci�n de pixeles
    index = ML == s(i);
    Mask(index) = 0;
end

[ML, GT] = bwlabel(Mask);   % Etiquetar granos de frijol conectados
exemplar =  1:1:GT;         % de 1 en 1 hasta total de granos
shufled = exemplar(randperm(length(exemplar))); % permutacion
n = NumSections;
M = cell(n, 2);
disp(['Número de granos totales de la muestra: ', num2str(GT)]);
numSeeds = floor(length(exemplar)/n);
remain =  (length(exemplar)/n)-floor(length(exemplar)/n);
remain = uint8(remain*n);

if (GT<19)
    numParts = 2;
    for k = 1 : n
        if (k==9)
            numParts = 1;
        end
        if k ~= n
            valbeans = shufled(1:numParts);
            M{k,2} = valbeans;
            shufled(1:numParts) = [];
        else
            valbeans = shufled(1:end);
            M{k,2} = valbeans;
            shufled(1:end) = [];
        end
        c = setdiff(exemplar, valbeans);
        MaskFrac = Mask;
        for i=1:length(c)
            index = ML == c(i);
            MaskFrac(index) = 0;
        end
        M{k, 1} = ~MaskFrac;
    end
else % mayor de 20 granos    
    disp(['Número de granos por representación de datos: ',num2str(numSeeds)]);
    for k = 1 : n
        numParts = numSeeds + (remain-(remain-1));
        if remain > 0
            remain = remain - 1;
        end
        if k ~= n
            valbeans = shufled(1:numParts);
            M{k,2} = valbeans;
            shufled(1:numParts) = [];
        else
            valbeans = shufled(1:end);
            M{k,2} = valbeans;
            shufled(1:end) = [];
        end
        c = setdiff(exemplar, valbeans);
        MaskFrac = Mask;
        for i=1:length(c)
            index = ML == c(i);
            MaskFrac(index) = 0;
        end
        M{k, 1} = ~MaskFrac;
    end
    
end

end

