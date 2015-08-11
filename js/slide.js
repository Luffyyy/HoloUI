var imgcount = 1;
var tot_imgs = 3;
/* exported slider */
AutoSlide();
function AutoSlide()
{  



}
function slider(x)
{
    "use strict";
	imgcount = imgcount + x;
	if(imgcount > tot_imgs){
            imgcount = 1;
	}
	if(imgcount < 1){
	    imgcount = tot_imgs;
	}
	ImgHide();
}
	
function ImgHide()
{
	//document.getElementById('slide-img').style.opacity = "0";
	setTimeout('ImgShow()',300);
}
function ImgShow()
{
	document.getElementById('slide-img').src = "img/img"+ imgcount +".jpg";
	document.getElementsByClassName("fancybox")[0].href = "img/img"+ imgcount +".jpg";
	//document.getElementById('slide-img').style.opacity = "1";
}
function ImgNext()
{
	imgcount = imgcount + 1
	if(imgcount > tot_imgs){
            imgcount = 1;
	}
	ImgHide();
}