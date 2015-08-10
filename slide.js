var imgnum = 1;
var tot_imgs = 5;

function slider(x){
	var Image = Document.getElementById()('screen');
	imgnum = imgnum + x;
	if(imgnum > tot_imgs){
    imagecount = 1;
    }
    if(imgnum < tot_imgs){
    imagecount = tot_imgs;
    }
	Image.src = "img/screen" + imgnum + ".png";

}
