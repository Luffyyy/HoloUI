var CurrentImg = 1;
var OldImg = 1
var Imgs = 3;
AutoSlide();
function AutoSlide()
{  
    Slide(1);       
    setTimeout("AutoSlide()", 5000);   
}
function Slide(x)
{
    "use strict";
    OldImg = CurrentImg
    CurrentImg = CurrentImg + x;
    if(CurrentImg > Imgs){
        CurrentImg = 1;
    }
    if(CurrentImg < 1){
        CurrentImg = Imgs;
    }
    setTimeout("ImgSwitch()", 300);
}
function ImgSwitch()
{
    document.getElementsByClassName('slide-imgs')[OldImg - 1].style.left = "200px";
    document.getElementsByClassName('slide-imgs')[OldImg - 1].style.opacity = 0;
    document.getElementsByClassName('slide-imgs')[CurrentImg - 1].style.opacity = 1;
    document.getElementsByClassName('slide-imgs')[CurrentImg - 1].style.left = "0px";
}
