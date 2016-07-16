/**
 * Created by rajeshkumarsheela 
 */

var request;
function Check(val)
{
    var f=document.getElementById("f").value;
    var s=document.getElementById("s").value;
    var ac=val;
    var url="/cgi-bin/cal.py?f="+f+"&s="+s+"&ac="+ac+"";
   //document.getElementById('result').innerHTML=url;

        request=new XMLHttpRequest();
    try{
        request.onreadystatechange=getInfo;
        request.open("POST",url,true);
        request.send();
    }catch(e){alert("Unable to connect to server");}
}

function getInfo(){
    if(request.readyState==4){
        var val=request.responseText;
        document.getElementById('result').innerHTML=val;
        //alert(val);
    }
}