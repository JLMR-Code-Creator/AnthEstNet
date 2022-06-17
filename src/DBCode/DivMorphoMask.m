function DivMorphoMask(pathImg, pathDB, type)
tic;
%imgLandraces = dir(strcat(pathImg,'*.tif')); % Cargar todas las muestras de entrenamiento
if ~exist('',pathDB)
    mkdir(pathDB);
end

N = 20;      % indicate the number of data structures
for i = 1:N  % 1 to N
    tic;
    disp([datestr(datetime),' Execution ' num2str(i) ' started...']);
    disp(['................Data estructure number : ', num2str(i)]);
    [ db1] = data2StructureDB40P(pathImg, type);
    %% Save datas
    dataset = db1;
    completo = strcat('DB_setMasks_run',num2str(i),'_',datestr(date),'.mat');
    nombredatos = strcat(pathDB, completo);
    save(nombredatos,'dataset', '-v7.3');
    disp([datestr(datetime),' Execution ' num2str(i) ' finished...']);
    toc;
end

end

function [ output1] = data2StructureDB40P(pathImg, type)
[landraces, anthocyanins] = dbAnthocyanins();
output1 = [];
for j = 1:length(landraces)
    LandraceName = landraces(j, 1);  % Image of landraces
    LandraceName = LandraceName{1};
    disp([datestr(datetime), ' Processing landrace ',LandraceName]);
    binaryMask=strcat(pathImg,'Masks/');
    L = load(strcat(binaryMask, LandraceName)); % Load file mask
    Mask = uint8(L.Mask);
    color = landraces(j, 2);
    color = color{1};
    valantocianinas = anthocyanins(j, :);

    [W] = BinaryROI2Split8ROIs(Mask, 4); % divide four parts
     M = cell(4, 3);
    for k = 1:length(W)
       Mask = W{k, 1};
       Mask = uint8(Mask);
       [ Mask_e, Mask_v, Mask_p ] = mask2TrainingAndTest(Mask, .70, .15);
       M{k, 1} = Mask_e;
       M{k, 2} = Mask_v;
       M{k, 3} = Mask_p;
    end   

    dbd1 = {M, valantocianinas, LandraceName, color};
    
    disp([datestr(datetime), LandraceName, ' Processed']);
    output1 = [output1;dbd1];
end


end

