var CurrentImg = 1;
var Imgs = 3;
AutoSlide();
function AutoSlide()
{  
    Slide(1);       
    setTimeout("AutoSlide", 3000);   
}
function Slide(x)
{
    "use strict";
    CurrentImg = CurrentImg + x;
    if(CurrentImg > Imgs){
        CurrentImg = 1;
    }
    if(CurrentImg < 1){
        CurrentImg = Imgs;
    }
    ImgHide();
}
    
function ImgHide()
{
    setTimeout("ImgShow()", 300);
}
function ImgShow()
{
    document.getElementsByClassName('slide-imgs')[0] = "img/img"+ CurrentImg +".jpg";
   // document.getElementsByClassName("fancybox")[0].href = "img/img"+ CurrentImg +".jpg";
}
