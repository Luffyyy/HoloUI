var CurrentImg = 1;
var Imgs = 3;
AutoSlide();
function AutoSlide()
{  
    var SlideNextFunc = function(){
        Slide(1);       
        setTimeout("SlideNextFunc", 3000);   
    }
    SlideNextFunc();
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
    console.log(document.getElementById('img.slide-imgs'));
    //document.getElementById('img.slide-imgs').src = "img/img"+ CurrentImg +".jpg";
    document.getElementsByClassName("fancybox")[0].href = "img/img"+ CurrentImg +".jpg";
}
