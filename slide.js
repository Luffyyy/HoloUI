var imgcount = 1;
var tot_imgs = 3;

function slider(x) {
	var image = document.getElementById('slide-img');
	imgcount = imgcount + x;
	if(imgcount > tot_imgs){
            imgcount = 1;
	}
	if(imgcount < 1){
	    imgcount = tot_imgs;
	}
  	image.src = "img/img"+ imageCount +".jpg";
}
	
