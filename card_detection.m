location = 'C:\Users\User\Desktop\BIM 472 2020 PROJECT\images';
ds = imageDatastore(location);
while hasdata(ds)
    img = read(ds) ;
    if size(img,1) < size(img,2)
      img = imrotate(img,90);
    end
    image = imadjust(img(:,:,3));
    threshold = graythresh(image);
    output = imbinarize(image,threshold);
    gaussian_filter = fspecial('gauss',20,30);
    im = imfilter(output,gaussian_filter,'same','repl');
    im = medfilt2(im);
    [separations,n_labels] = bwlabel(im);
    for ii = 1:n_labels
      oneregion = (separations==ii);
      s = regionprops(oneregion,'ConvexHull','Area','Centroid','Orientation', 'BoundingBox');
      if (s.Area <=70000)
          continue
      end
      subimage = imcrop(output, s.BoundingBox);
      BW = edge(subimage, 'canny', 0.5);
      [H,T,R] = hough(BW, 'RhoResolution', 2);      
      axis on, axis normal, hold on;
      P = houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));
      x = T(P(:,2));
      y = R(P(:,1));
      plot(x,y,'s','color','blue');
      lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',20);
      figure;
      max_len = 0;
      for k = 1:length(lines)
      xy = [lines(k).point1; lines(k).point2];
      plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','red');
      end 
      angle = s.Orientation;
      uprightImage = imrotate(subimage,90-angle);
      [rows, columns] = find(uprightImage);
      topRow = min(rows);
      bottomRow = max(rows);
      leftColumn = min(columns);
      rightColumn = max(columns);
      cropped_card= uprightImage(topRow:bottomRow, leftColumn:rightColumn);
      imshow(subimage);
    end   
end 