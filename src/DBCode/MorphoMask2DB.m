function MorphoMask2DB(pathImg, pathDB, file, dirOut)

dbmorphoMask = dir(strcat(pathDB,file)); % Cargar todas las muestras de entrenamiento
N=length(dbmorphoMask);
finalDir = strcat(pathDB, dirOut);
if ~exist('',finalDir)
    mkdir(finalDir);
end
for i = 1 : N
    dbfile = dbmorphoMask(i).name;       % Nombre de la db
    disp(dbfile);
    createDataSet(pathImg, pathDB, dbfile, finalDir);
end


end
function createDataSet(pathImg, pathDB, dbfile, dirOut)
db = load(strcat(pathDB,dbfile),'-mat');
data_set = db.dataset;

% Training 70%  Validation 15%   Testing 15% (ANN, CNN)
XTrainHSI = []; XValidationHSI = []; XTestHSI = [];
YTrainHSI = []; YValidationHSI = []; YTestHSI = [];

XTrainLAB = []; XValidationLAB = []; XTestLAB = [];
YTrainLAB = []; YValidationLAB = []; YTestLAB = [];

CTrainLandraces = []; CValidationLandraces = []; CTestLandraces = [];
CTrainColor = []; CValidationColor = [];   CTestColor = [];

AVG_E_HSI = []; AVG_V_HSI = []; AVG_P_HSI = [];
AVG_E_LAB = []; AVG_V_LAB = []; AVG_P_LAB = [];

% Training 70% Testing 30% (Regress)
REG_AVG_E_HSI = []; REG_AVG_P_HSI = [];
REG_AVG_E_LAB = []; REG_AVG_P_LAB = [];

REG_H2D_E_HSI = []; REG_H2D_P_HSI = [];
REG_H2D_E_LAB = []; REG_H2D_P_LAB = [];


for j = 1 : size(data_set, 1)
    M = data_set(j, 1); M = M{1};
    anthocyanin = data_set(j, 2); anthocyanin = anthocyanin{1};
    landraces = data_set(j, 3); landraces = landraces{1};
    color =  data_set(j, 4); color =  color{1};
    disp([datestr(datetime), ' Processing landraces ',landraces]);
    I_rgb = imread(strcat(pathImg,landraces, '.tif'));
    Lab = ColorCalibration(I_rgb); %RGB to CIE L*a*b*
    I = uint8(I_rgb / 256);
    n = length(M);
    for k = 1 : n
        
        %% ===================TRAINING
        Mask = M{k, 1};     % Training
        [averageLab, ~, averageHSI] = Promedio(I, Lab, Mask);
        [HSI_E_HS] = Img2Hist2DHSI(I, Mask); 
        [CIE_E_AB] = Img2Hist2DLab(Lab, Mask);       
        value = anthocyanin(k);
        
        XTrainHSI = cat(4, XTrainHSI, HSI_E_HS);
        YTrainHSI = [YTrainHSI; value];
        XTrainLAB = cat(4, XTrainLAB, CIE_E_AB);
        YTrainLAB = [YTrainLAB; value];
        CTrainLandraces = [CTrainLandraces;{landraces}];
        CTrainColor = [CTrainColor;{color}];
        % Average for ANN
        AVG_E_HSI = [AVG_E_HSI; averageHSI];
        AVG_E_LAB = [AVG_E_LAB; averageLab];
        % Average for Regression
        REG_AVG_E_HSI = [REG_AVG_E_HSI; averageHSI];
        REG_AVG_E_LAB = [REG_AVG_E_LAB; averageLab]; 
        % Histogram for Regression
        REG_H2D_E_HSI = cat(4, REG_H2D_E_HSI, HSI_E_HS);
        REG_H2D_E_LAB = cat(4, REG_H2D_E_LAB, CIE_E_AB);
               
        %% =================VALIDATION
        Mask = M{k, 2};  % Validation
        [averageLab, ~, averageHSI] = Promedio(I, Lab, Mask);
        [HSI_E_HS] = Img2Hist2DHSI(I, Mask); 
        [CIE_E_AB] = Img2Hist2DLab(Lab, Mask);       
                
        XValidationHSI = cat(4, XValidationHSI, HSI_E_HS);
        YValidationHSI = [YValidationHSI;value];
        XValidationLAB = cat(4, XValidationLAB, CIE_E_AB);
        YValidationLAB = [YValidationLAB;value];
        CValidationLandraces = [CValidationLandraces;{landraces}];
        CValidationColor = [CValidationColor;{color}];
        % Average for ANN
        AVG_V_HSI = [AVG_V_HSI;averageHSI];
        AVG_V_LAB = [AVG_V_LAB;averageLab];
        %% ==================TESTING
        Mask = M{k, 3};  % Testing 
        [averageLab, ~, averageHSI] = Promedio(I, Lab, Mask);
        [HSI_E_HS] = Img2Hist2DHSI(I, Mask); 
        [CIE_E_AB] = Img2Hist2DLab(Lab, Mask);          
        
        XTestHSI = cat(4, XTestHSI, HSI_E_HS);
        YTestHSI = [YTestHSI;value];
        XTestLAB = cat(4, XTestLAB, CIE_E_AB);
        YTestLAB = [YTestLAB;value];
        CTestLandraces = [CTestLandraces;{landraces}];
        CTestColor = [CTestColor;{color}];
        % Average for ANN
        AVG_P_HSI = [AVG_P_HSI; averageHSI];
        AVG_P_LAB = [AVG_P_LAB; averageLab];
        %% ======== JOIN VALIDATION AND TESTING (REGRESSION)
        memoryMask = ~M{k, 2} + ~M{k, 3}; % Join mask 15%  + 15%  = 30%
        memoryMask = ~memoryMask;
        [averageLab, ~, averageHSI] = Promedio(I, Lab, memoryMask);
        [HSI_E_HS] = Img2Hist2DHSI(I, Mask); 
        [CIE_E_AB] = Img2Hist2DLab(Lab, Mask);       

        REG_AVG_P_HSI = [REG_AVG_P_HSI; averageHSI];
        REG_AVG_P_LAB = [REG_AVG_P_LAB; averageLab];
        REG_H2D_P_HSI = cat(4, REG_H2D_P_HSI, HSI_E_HS);
        REG_H2D_P_LAB = cat(4, REG_H2D_P_LAB, CIE_E_AB);
        
    end
end
nameVector = split(dbfile, '_');
completo = strcat(nameVector(1),'_',nameVector(3),'_',nameVector(4));
nombredatos = strcat(dirOut,'/', completo{1});
save(nombredatos, 'XTrainHSI', 'XValidationHSI', 'XTestHSI', ...
    'YTrainHSI', 'YValidationHSI', 'YTestHSI', ...
    'XTrainLAB', 'XValidationLAB' , 'XTestLAB', ...
    'YTrainLAB', 'YValidationLAB', 'YTestLAB', ...
    'CTrainLandraces', 'CValidationLandraces', 'CTestLandraces', ...
    'CTrainColor', 'CValidationColor', 'CTestColor', ...
    'AVG_E_HSI', 'AVG_V_HSI', 'AVG_P_HSI', ...
    'AVG_E_LAB', 'AVG_V_LAB', 'AVG_P_LAB', ...
    'REG_AVG_E_HSI', 'REG_AVG_P_HSI', 'REG_AVG_E_LAB', 'REG_AVG_P_LAB', ... 
    'REG_H2D_E_HSI', 'REG_H2D_P_HSI', 'REG_H2D_E_LAB', 'REG_H2D_P_LAB');
end
