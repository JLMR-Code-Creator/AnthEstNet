function [ Mask_e, Mask_v, Mask_p ] = mask2TrainingAndTest(Mask, p1, p2)
 % mask2trainingandtest Procesamiento binario de la mascara se segmentación
 % eliminación de regiones con pocos pixeles y separación de la mascara
 % para obtención de granos de muestra de entrenamiento y de prueba
 % Mask: imagen binaria.
 % Resultado 
 % Mask_e : matriz de nxm con valores binarios.
 % Mask_v : matriz de nxm con valores binarios.

   if ~isnumeric(Mask)
      error('MyComponent:incorrectType',...
      'Error. \nEntrada debe ser tipo logical, y no del tipo %s.',class(Mask));
   end
   Mask = ~Mask;   
   % Limpieza de pixeles
   [ML, ~]=bwlabel(Mask);         % Etiquetar granos de frijol conectados
   propied= regionprops(ML);      % Calcular propiedades de los objetos de la imagen
   s=find([propied.Area] < 1000); % grupos menores a 100 px
   for i=1:size(s,2)              % eliminación de pixeles
       index = ML == s(i);
       Mask(index) = 0;
   end
   
   %Mascaras de segmentación para granos de frijol para entrenamiento y prueba
   Mask_e  = uint8(Mask); % Entrenamiento
   Mask_v  = uint8(Mask); % Validación
   Mask_p  = uint8(Mask); % Prueba
   [ML, GT] = bwlabel(Mask);   % Etiquetar granos de frijol conectados
   exemplar =  1:1:GT;         % de 1 en 1 hasta total de granos
   shufled = exemplar(randperm(length(exemplar))); % permutacion 
   nEntrenamiento = round(GT*p1);
   nValidacion = round(GT*p2);
   
   %N = round(GT/2);  % División para entrenamiento y validación
   %Son seleccionados todos los que no son de entrenamiento
   trainingbeans = shufled(nEntrenamiento+1:end);
   for i=1:length(trainingbeans)
       index = ML == trainingbeans(i);
       Mask_e(index) = 0;
   end
   % Todos los granos de entrenamiento
   testbeans = shufled(1:nEntrenamiento);
   % Los granos de validación y quedan los granos de entrenamiento.
   testbeans = [testbeans, shufled(nEntrenamiento+nValidacion+1:end)];
   for i=1:length(testbeans)
       index = ML == testbeans(i);
       Mask_v(index) = 0;
   end   
   %Todos los granos de entrenamiento
   valbeans = shufled(1:nEntrenamiento+nValidacion);
   for i=1:length(valbeans)
       index = ML == valbeans(i);
       Mask_p(index) = 0;
   end   
   Mask_e = ~Mask_e;  
   Mask_v = ~Mask_v;  
   Mask_p = ~Mask_p;  
end
