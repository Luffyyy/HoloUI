var imageCount = 1;
var total = 6;

function slider(x) {
	var image = document.getElementById('slide-img');
	imageCount = imageCount + x;
	if(imageCount > total){imageCount = 1;}
	if(imageCount < 1){imageCount = total;}	
	image.src = "img/img1"+ imageCount +".png";
	}
	
