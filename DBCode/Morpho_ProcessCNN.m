function Morpho_ProcessCNN(pathDB, file, epoch, dirOut)
  dbPopulations = dir(strcat(pathDB,file)); % Cargar todas las muestras de entrenamiento
  N=length(dbPopulations);
  finalDir = strcat(pathDB, dirOut);
  if ~exist('',finalDir)
     mkdir(finalDir);
  end
  %H2D_HSI_CNN(pathDB, dbPopulations, N, epoch, finalDir);
  H2D_LAB_CNN(pathDB, dbPopulations, N, epoch, finalDir);
end

function H2D_HSI_CNN(pathDB, dbPopulations, N, epoch, finalDir)
  container = [];
  for i = 1 : N % Parfor debe ser desde este punto
     dbfile = dbPopulations(i).name;       % Nombre de la db
     disp(dbfile);     
     [YPredTest1, YPredTrain1, YPredValidation1, YTrain, poblaciones, colores] = TrainCNNDB12HS(pathDB, dbfile, epoch);
     container=[container; YPredTest1, YPredTrain1, YPredValidation1, YTrain, {poblaciones}, {colores}, {i}, {dbfile}];
     delete(findall(0));   
  end 
  completo = strcat('/Resultado_40P_2D_HS_CNN','_',datestr(date),'.mat');
  nombredatos = strcat(finalDir, completo);
  save(nombredatos, 'container')
  delete(findall(0));   
end

function H2D_LAB_CNN(pathDB, dbPopulations, N, epoch, finalDir)
  container = [];
  for i = 1 : N % Parfor debe ser desde este punto
     dbfile = dbPopulations(i).name;       % Nombre de la db
     disp(dbfile);     
     [YPredTest1, YPredTrain1, YPredValidation1, YTrain, poblaciones, colores] = TrainCNNDB12AB(pathDB, dbfile, epoch);
     container=[container; YPredTest1, YPredTrain1, YPredValidation1, YTrain, {poblaciones}, {colores}, {i}, {dbfile}];  
     delete(findall(0)); 
  end
  completo = strcat('/Resultado_40P_2D_AB_CNN','_',datestr(date),'.mat');
  nombredatos = strcat(finalDir, completo);
  save(nombredatos, 'container')
  
end

function [YPredTest1, YPredTrain1, YPredValidation1, YTrain, poblaciones, colores] = TrainCNNDB12HS(DBSource, dbfile, epoch)
  load(strcat(DBSource,dbfile),'-mat');
  
  XTrain = XTrainHSI; YTrain = YTrainHSI;
  XValidation = XValidationHSI; YValidation = YValidationHSI;
  XTest = XTestHSI; YTest = YTestHSI;
  XTrainPop = CTrainLandraces;
  YTrainColor = CTrainColor;
  [YPredTest1, YPredTrain1, YPredValidation1, YTrain, ...
          poblaciones, colores] = ProcessCNN(XTrain, YTrain, XValidation, YValidation, XTest, YTest, XTrainPop, YTrainColor, epoch);
end

function [YPredTest1, YPredTrain1, YPredValidation1, YTrain, poblaciones, colores] = TrainCNNDB12AB(DBSource, dbfile, epoch)
  load(strcat(DBSource,dbfile),'-mat');
  XTrain = XTrainLAB; YTrain = YTrainLAB;
  XValidation = XValidationLAB; YValidation = YValidationLAB;
  XTest = XTestLAB; YTest = YTestLAB;
  XTrainPop = CTrainLandraces;
  XTrainColor = CTrainColor;
  [YPredTest1, YPredTrain1, YPredValidation1, YTrain, ...
          poblaciones, colores] = ProcessCNN(XTrain, YTrain, XValidation, YValidation, XTest, YTest, XTrainPop, XTrainColor, epoch);
end

function [YPredTest1, YPredTrain1, YPredValidation1, YTrain, ...
          poblaciones, colores] = ProcessCNN(XTrain, YTrain, XValidation, YValidation, XTest, YTest, XTrainPop, XTrainColor, epoch)

  rng('default'); rng(0, "threefry"); gpurng(0, "threefry");     
  altura = 256; ancho =  256;
  canales = 1;
  imageSize = [altura ancho canales];
  inputLayer = imageInputLayer(imageSize);
  sizeFilter = [7 7];  filtros  = 16;

  middleLayers = [
  convolution2dLayer(sizeFilter, filtros, 'Padding', 2);
  batchNormalizationLayer
  reluLayer();
  maxPooling2dLayer(2, 'Stride', 2);

    % Stack 2
  convolution2dLayer(sizeFilter, filtros+2, 'Padding', 2); 
  batchNormalizationLayer
  reluLayer();
  maxPooling2dLayer(2, 'Stride',2);

    % Stack 3
  convolution2dLayer(sizeFilter, filtros+2, 'Padding', 2); 
  batchNormalizationLayer
  reluLayer();
  maxPooling2dLayer(2, 'Stride',2);

    % Stack 4
  convolution2dLayer(sizeFilter, filtros+2, 'Padding', 2); 
  batchNormalizationLayer
  reluLayer();
  maxPooling2dLayer(2, 'Stride',2);

    % Stack 5
  convolution2dLayer(sizeFilter, filtros+2, 'Padding', 2); 
  batchNormalizationLayer
  reluLayer();
  maxPooling2dLayer(2, 'Stride',2);
    % Stack 6
  convolution2dLayer(sizeFilter, filtros+2, 'Padding', 2); 
  batchNormalizationLayer
  reluLayer();
  ] 

  finalLayers = [
    fullyConnectedLayer(1)
    regressionLayer  
  ]
  layers = [
    inputLayer
    middleLayers
    finalLayers
  ]
  % Valores aleatorios para los pesos de las capas ocultas
  layers(2).Weights = 0.0001 * randn([sizeFilter canales filtros]);

  options = trainingOptions('sgdm',...
        'InitialLearnRate',0.001, ...
        'ValidationData',{XValidation,YValidation},...
        'Plots','training-progress',...
        'MaxEpochs', epoch,...
        'Verbose',true);

  net = trainNetwork(XTrain,YTrain,layers,options);
   
  YPredTest = predict(net, XTest);
  YPredTest1 = reshape(YPredTest,[4, 40] );
  %Predition 
  YPredTrain = predict(net, XTrain);
  YPredTrain1 = reshape(YPredTrain,[4, 40] );
    
  YPredValidation = predict(net, XValidation);
  YPredValidation1 = reshape(YPredValidation,[4, 40] );
 
  YTrain = reshape(YTrain,[4, 40]);
   
  poblaciones = unique(XTrainPop);
  poblaciones = poblaciones';
  color = reshape(XTrainColor, [4, 40]);
  colores =  color(1, :);

end




