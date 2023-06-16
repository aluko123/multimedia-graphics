function output = project4(imageFile, qf)
    
    %read image file
    %imageFile = imread(imageFile);

    %disp(size(rgbImage));

    %printing out the 8x8 pixel values
    disp("Original Image Output");
    disp(imageFile(1:8, 1:8));


    %converting to ycbcrImage
    Y = 0.299*double(imageFile(:,:,1)) + 0.587*double(imageFile(:,:,2)) + 0.114*double(imageFile(:,:,3)) + 0;
    Cb = -0.16874*double(imageFile(:,:,1)) - 0.33126*double(imageFile(:,:,2)) + 0.5*double(imageFile(:,:,3)) + 0.5;
    Cr = 0.5*double(imageFile(:,:,1)) - 0.41869*double(imageFile(:,:,2)) - 0.08131*double(imageFile(:,:,3)) + 0.5;

    %combine into one image
    ycbcrImage = cat(3, Y, Cb, Cr);
    %printing out the 8x8 pixel values
    disp("YCbCr Image Output");
    disp(ycbcrImage(1:8, 1:8, :));

    %save ycbcrImage
    %h = imshow(uint8(ycbcrImage));
    %imsave(h);

    %disp(size(ycbcrImage));


    %perform 4:2:2 subsampling on Cb and Cr components
    %Divide into 2x4 blocks and select every two pixels as the subsampled
    %value

    subsampled_Cb = Cb(:, 1:2:end);
    subsampled_Cr = Cr(:, 1:2:end);
    
    %resize
    subsampled_Cb = kron(subsampled_Cb, ones(1, 2));
    subsampled_Cr = kron(subsampled_Cr, ones(1, 2));



    %combine both components into one image
    subYCbCrImg = cat(3, Y, subsampled_Cb, subsampled_Cr);

    %printing out the 8x8 pixel values
    disp("Chroma Subsampling Image Output");
    disp(subYCbCrImg(1:8, 1:8, :));

    %save subsampled image
    %h = imshow(uint8(subYCbCrImg));
    %imsave(h);

    % Get size of input image
    [rows, cols, channels] = size(subYCbCrImg);
    
    % Make sure rows and cols are multiples of 8
    if mod(rows,8) ~= 0 || mod(cols,8) ~= 0
        rows = rows - mod(rows,8);
        cols = cols - mod(cols,8);
        fprintf("Warning: Image size adjusted to [%d, %d]\n", rows, cols);
        subYCbCrImg = subYCbCrImg(1:rows,1:cols,:);
    end


    

    %perform dctTransformation
    dctImg = dctTransform(subYCbCrImg);

    %printing out the 8x8 pixel values
    disp("DCT Transform Image Output");
    disp(dctImg(1:8, 1:8, :));

    %save DCT image
    %h = imshow(uint8(dctImg));
    %imsave(h);

    %Need to import quantization tables for quantization purposes and
    %begine quantize process
    quantize1 = ones(8);
    
    lQuantize = [16 11 10 16 24 40 51 61; ...
                 12 12 14 19 26 58 60 55; ...
                 14 13 16 24 40 57 69 56; ...
                 14 17 22 29 51 87 80 62; ...
                 18 22 37 56 68 109 103 77; ...
                 24 35 55 64 81 104 113 92; ...
                 49 64 78 87 103 121 120 101; ...
                 72 92 95 98 112 100 103 99];

    cQuantize = [17 18 24 47 99 99 99 99; ...
                 18 21 26 66 99 99 99 99; ...
                 24 26 56 99 99 99 99 99; ...
                 47 66 99 99 99 99 99 99; ...
                 99 99 99 99 99 99 99 99; ...
                 99 99 99 99 99 99 99 99; ...
                 99 99 99 99 99 99 99 99; ...
                 99 99 99 99 99 99 99 99];


    %applying scaling factor
    if qf >= 50
        scaling_factor = (100 - qf)/50;
    else
        scaling_factor = (50/qf);
    end

    if scaling_factor ~= 0  %if qf is not 100
        newlQuantize = round (lQuantize * scaling_factor);
        newcQuantize = round (cQuantize * scaling_factor);
    else
        newlQuantize = quantize1;  %no quanitzation
        newcQuantize = quantize1;  %no quantization
    end

    newlQuantize = uint8(newlQuantize);  %max is clamped to 255 for qf=1
    newcQuantize = uint8(newcQuantize);  %max is clamped to 255 for qf=1

    %to put the data in the same class
    newlQuantize = double(newlQuantize);
    newcQuantize = double(newcQuantize);

    


    %get channels from DCT image
    yDCT = dctImg(:,:,1);
    cbDCT = dctImg(:,:,2);
    crDCT = dctImg(:,:,3);

    %quantize DCT channels using scaled quantized value
    yQuantized = blockproc( yDCT, [8 8], @(block_struct) round(round(block_struct.data) ./ newlQuantize));
    cbQuantized = blockproc( cbDCT, [8 8], @(block_struct) round(round(block_struct.data) ./ newcQuantize));
    crQuantized = blockproc( crDCT, [8 8], @(block_struct) round(round(block_struct.data) ./ newcQuantize));


    %bring into one channel
    quantizedImage = cat(3, yQuantized, cbQuantized, crQuantized);

    %printing out the 8x8 pixel values
    disp("Quantized Image Output");
    disp(quantizedImage(1:8, 1:8, :));

    %save quantized image
    %h = imshow(uint8(quantizedImage));
    %imsave(h);

    % % using a for loop to quantize DCT channels using scaled quantized value
    %  yQuantized = zeros(size(yDCT));
    %  cbQuantized = zeros(size(cbDCT));
    %  crQuantized = zeros(size(crDCT));
    % 
    % 
    % % loop through the blocks
    %  for i = 1:8:size(yDCT, 1)
    %      for j = 1:8:size(yDCT, 2)
    %          rowIndices = i:i+7;
    %          colIndices = j:j+7;
    % 
    %          %division
    %          yQuantized(rowIndices, colIndices) = yDCT(rowIndices, colIndices) ./ newlQuantize;
    %      end
    %  end
    
    
    %now dequantize same channels
    yQuantized = blockproc(yQuantized, [8 8], @(block_struct) block_struct.data .* newlQuantize);
    cbQuantized = blockproc(cbQuantized, [8 8], @(block_struct) block_struct.data .* newcQuantize);
    crQuantized = blockproc(crQuantized, [8 8], @(block_struct) block_struct.data .* newcQuantize);


    %applying 2D IDCT to dequantized coefficients
    inputImage = cat(3, yQuantized, cbQuantized, crQuantized);

    %printing out the 8x8 pixel values
    disp("Dequantized Image Output");
    disp(inputImage(1:8, 1:8, :));

    %save dequantized image
    %h = imshow(uint8(inputImage));
    %imsave(h);

    %perform Idct on the image
    idctImage = idctTransform(inputImage);
    
    %printing out the 8x8 pixel values
    disp("IDCT Transform Image Output");
    disp(idctImage(1:8, 1:8, :));
    
    %save IDCT image
    %h = imshow(uint8(idctImage));
    %imsave(h);


    %seperate IDCT channels
    yIdctImage = idctImage(:,:,1);
    cbIdctImage = idctImage(:,:,2);
    crIdctImage = idctImage(:,:,3);
 
    %convert resulting image to RGB channel
    R1 = 1*double(yIdctImage(:,:)) + 0*double(cbIdctImage(:,:) - 0.5) + 1.402*double(crIdctImage(:,:) - 0.5);
    G1 = 1*double(yIdctImage(:,:)) - 0.34414*double(cbIdctImage(:,:) - 0.5) - 0.71414*double(crIdctImage(:,:) - 0.5);
    B1 = 1*double(yIdctImage(:,:)) + 1.77200*double(cbIdctImage(:,:) - 0.5) + 0*double(crIdctImage(:,:) - 0.5);

    output = cat(3, R1, G1, B1);
    output = uint8(output);
    
    %rgbImg = ycbcr2rgb(idctImage);



    %display RGB image
    %h = imshow(output);

    %imsave(h);









                


    

