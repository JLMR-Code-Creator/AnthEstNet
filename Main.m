Head.Library;
% Segmentation
Impl_Segmentation('src/Images/','*.tif');
% Creation of structures as of mask
DivMorphoMask('src/Images/', 'src/Images/DB_StructMask/', 40);
%Binary images or masks to data set
MorphoMask2DB('src/Images/', 'src/Images/DB_StructMask/', '*.mat', 'DataCenter');
%Dataset to leaning aprouches

% Average and Regression
  val = Morpho_Regression('src/Images/DB_StructMask/DataCenter/', '*.mat', 1, 1, 0,'Report40AVG_Reg', '','','','');

% PCA and Regression
   vec = 3:30;
   val = Morpho_MultiRegression('src/Images/DB_StructMask/DataCenter/', '*.mat', vec, 1, 2, 'Report402D_Regress', '', '', '', '');


% Average  and ANN
    val = Morpho_ANN('src/Images/DB_StructMask/DataCenter/', '*.mat', 1, 1, 0, 0, 'Report40AVG_ANN', '', '', '', '');


% PCA and ANN
    vec = 3:30;
    val = Morpho_MultiANN('src/Images/DB_StructMask/DataCenter/', '*.mat', vec, 1, 2, 'Report402D_ANN', '', '', '', '');

  %PMF and AntEstNet 
   Morpho_ProcessCNN('src/Images/DB_StructMask/DataCenter/', '*.mat', 500, 'Report_40P_CNN_500')


