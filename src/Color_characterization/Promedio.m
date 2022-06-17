
function [averageLab, averageRGB, averageHSI] = Promedio(Irgb,ILab, Mask)

    [global_rows, global_cols, ~] = size(Irgb);
    MaskV=reshape(Mask,global_rows * global_cols, 1);
    indices = find(MaskV == 0);

    %% RGB
    img = Irgb;
    %img = uint8(img / 256);
    data_raw = reshape(img, global_rows * global_cols, 3);
    dataRGB = data_raw(indices,:);
    dataRGB = round(dataRGB) + 1;    
    averageRGB=[mean(dataRGB(:,1)), mean(dataRGB(:,2)) , mean(dataRGB(:,3))];    
    %% cie L*A*B*
    img=ILab;
    data_raw=reshape(img,global_rows*global_cols,3);
    dataLab=data_raw(indices,:);    
    dataLab(:,1) = dataLab(:,1) / 100;     % l* normalizaci?n
    dataLab(:,1) = dataLab(:,1) * 255;     % l* escalado a 
    dataLab(:,1) = dataLab(:,1) + 1;       % desplazamiento en l, rango de 1/256
    dataLab(:,2:3) = dataLab(:,2:3) + 129; % Escala el rango de -128/127 a 1/256 a* b*
    dataLab = round(dataLab);     
    averageLab=[mean(dataLab(:,1)), mean(dataLab(:,2)), mean(dataLab(:,3))];
    %% HSI
    img = rgb2hsi(Irgb);
    data_raw = reshape(img, global_rows * global_cols, 3);
    datosHSI = data_raw(indices,:);  
    datosHSI = (datosHSI * 255) + 1; % Escalado y desplazamiento, rango de 1/256
    datosHSI = round(datosHSI);        
    averageHSI=[mean(datosHSI(:,1)), mean(datosHSI(:,2)) , mean(datosHSI(:,3))];
    %% cie L*A*B*        
end

