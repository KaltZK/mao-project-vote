var selected_mark=Array(OPTIONS_MAX);
var selected_num,ques;
var q_index=0,result={},data=[];
var syms={};
function record(){
	if(ques.type=="multi"){
		result[ques.ques]=selected_mark.map(function(v){return ques.options[v];});
		setTimeout(next,TIMEOUT);
	}
}
function go_back(){
	setTimeout(function(){
		q_index--;
		next();
	},TIMEOUT);
}
function select(index){
	var ele=document.getElementById("option_"+index);
	if(ques.type=="multi"){
		if(selected_mark[index]!=undefined){
			ele.classList.remove("btn-success");
			ele.classList.add("btn-default");
			selected_mark[index]=undefined;
		}else{
			ele.classList.remove("btn-default");
			ele.classList.add("btn-success");
			selected_mark[index]=index;
		}
	}else{
		result[ques.ques]=ques.options[index];
		if(ques.sym)
			syms[ques.sym]=ques.options[index];
		setTimeout(next,TIMEOUT);
	}
}
function finish(){
    $.post("/submit_res",result,function(){
		window.location="/thank_you";
	});
}
function array_includes(array,target){
	for(var i=0;i<array.length;i++){
		if(array[i]==target)
			return true;
	}
	return false;
}
function next(){
	if(q_index==data.length){
		finish();
		return;
	}
	var q=ques=data[q_index++];
	if(ques.text){
		$("#about-text").css("display","block");
		$("#about-text").text(ques.text);
	}else{
		$("#about-text").css("display","none");
	}
	if(ques.when && !ques.when.every(function(w){
		for(var x in w){
			return array_includes(w[x],syms[x]);
		}
	})){
		next();
		return;
	}
	$("#ques").text(q.ques+(ques.type=="multi" ? "(多选)":""));
	for(var i=0;i<q.options.length;i++){
		$("#option_"+i).text(q.options[i]);
		$("#option_"+i).css("display","block");
		var ele=document.getElementById("option_"+i);
		ele.classList.remove("btn-success");
		ele.classList.add("btn-default");
        $("#ques_num").text("( "+q_index+" / "+data.length+" )");
	}
	for(var i=q.options.length;i<OPTIONS_MAX;i++)
		$("#option_"+i).css("display","none");
	if(q.type=="multi"){
		$("#next_btn").css("display","block");
	}else{
		$("#next_btn").css("display","none");
	}
}
$.getJSON("/questions",function(_data){
	data=_data;
	next();
});
$(document).on("keyup",function(evt){
	console.log(evt.which);
	if(evt.which>48 && evt.which <58)
		$("#option_"+(evt.which-49)).trigger('mousedown');
	else if(evt.which>96 && evt.which <106)
		$("#option_"+(evt.which-97)).trigger('mousedown');
	else if(evt.which==13 && $("#next_btn").css('display')!='none')
		$("#next_btn").trigger('mousedown');
});
