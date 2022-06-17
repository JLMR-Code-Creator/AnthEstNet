function [ hsi_hs] = Img2Hist2DHSI(I, Mask)  
    % Img2Hist2D genera matriz de probabilidad
    % conjunta en los espacios de color HSI y CIE L*A*B* considerando solo
    % los matices en los canales HS y AB.
    % I es una matriz de n x m x z que corresponden a una imagen de color
    % Mask matriz de nxm que corresponde a la mascara de segmentaci�n.
    % Resultado : 
    % hsi_hs: matriz de nxm con las probabilidades conjuntas de cada tono de color en
    % los componentes de H y S.
    % cie_ab: matriz de nxm con las probabilidades conjuntas de cada tono de color en
    % los componentes A* y B*
    
    %% Obtenci�n de indices
    [global_rows, global_cols, ~] = size(I);
    MaskV=reshape(Mask,global_rows * global_cols, 1);
    indices = find(MaskV == 0);

    %%  HSI     
    img = rgb2hsi(I);
    data_raw = reshape(img, global_rows * global_cols, 3);
    datosHSI = data_raw(indices,:);
    [rows, ~] = size(datosHSI);
    datosHSI = (datosHSI * 255) + 1; % Escalado y desplazamiento, rango de 1/256
    datosHSI = round(datosHSI);
    hsi_hs = zeros(256,256);    
    tic
    for i=1:rows 
        ind = datosHSI(i,:);
        hsi_hs(ind(1),ind(2)) = hsi_hs(ind(1), ind(2)) + 1;
    end    
    toc    
    hsi_hs = hsi_hs / rows;
    disp([datestr(datetime), ' Histograma 2D de HSI creado']);
end
