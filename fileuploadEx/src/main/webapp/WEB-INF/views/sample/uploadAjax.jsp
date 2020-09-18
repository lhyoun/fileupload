<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>

	<style>
.uploadResult {
	width: 100%;
	background-color: gray;
}

.uploadResult ul {
	display: flex;
	flex-flow: row;
	justify-content: center;
	align-items: center;
}

.uploadResult ul li {
	list-style: none;
	padding: 10px;
}

.uploadResult ul li img {
	width: 100px;
}
</style>

	<style>
.bigPictureWrapper {
	position: absolute;
	display: none;
	justify-content: center;
	align-items: center;
	top: 0%;
	width: 100%;
	height: 100%;
	background-color: gray;
	z-index: 100;
}

.bigPicture {
	position: relative;
	display: flex;
	justify-content: center;
	align-items: center;
}
</style>



	<div class='bigPictureWrapper'>
		<div class='bigPicture'></div>
	</div>

	<div class='uploadDiv'>
		<input type="file" name="uploadFile" multiple>
	</div>
	
	<div class='uploadResult'>
		<ul>
		
		</ul>
	</div>
	<button id="uploadBtn">upload</button>



	<!-- jquery CDN -->
	<script src="https://code.jquery.com/jquery-3.5.1.min.js"
		integrity="sha256-9/aliU8dGd2tb6OSsuzixeV4y/faTqgFtohetphbbj0="
		crossorigin="anonymous"></script>


<script type="text/javascript">
// upload된 파일 중 이미지 파일을 클릭하면 작동하는 함수
// 중요한 부분만 주석을 달겠음
function showImage(fileCallPath){
	  
	  $(".bigPictureWrapper").css("display","flex").show();
	  
	  $(".bigPicture")
	  // bigPicture영역이 처음에는 비어있는데 클릭을하면 채워진다
	  // 채워지는 이미지는 display로 요청을 해서 받아온다
	  .html("<img src='display?fileName="+fileCallPath+"'>")
	  .animate({width:'100%', height: '100%'}, 1000);
	}
	
	// 이거는 확대된 사진을 다시 누르면 작아지는 것에 대한 내용이다
	$(".bigPictureWrapper").on("click", function(e){
	  $(".bigPicture").animate({width:'0%', height: '0%'}, 1000);
	  setTimeout(() => {
	    $(this).hide();
	  }, 1000);
	});

	// sapn(그림 옆에 x표시)를 누르면 작동. ajax로 이 파일을 지워라고 요청함
	$(".uploadResult").on("click","span", function(e){
	  var targetFile = $(this).data("file");
	  var type = $(this).data("type");
	  console.log(targetFile);
	  
	  $.ajax({
	    url: 'deleteFile',
	    data: {fileName: targetFile, type:type},
	    dataType:'text',
	    type: 'POST',
	      success: function(result){
	         alert(result);
	       }
	  });
	});
	
// dom이 준비되면
$(document).ready(function(){
	
	var regex = new RegExp("(.*?)\.(exe|sh|zip|alz)$");
	// regexp는 javascript에 있는 정규식에 관련된 객체이다
	// 위의 식은 대충 저 애들이 확장자로 오면 안된다. 이런뜻 
	
	var maxSize = 5242880; //5MB

	// file이름과 사이즈를 넣으면 이 첨부파일을 업로드 할 수 있는지 리턴해준다
	// 업로드 불가능: false, 가능: true
	function checkExtension(fileName, fileSize) {
		//alert(fileName)

		if (fileSize >= maxSize) {
			alert("파일 사이즈 초과");
			return false;
		}

		if (regex.test(fileName)) {
			alert("해당 종류의 파일은 업로드할 수 없습니다.");
			return false;
		}
		return true;
	}
	
	// 결과적으로 업로드에 성공한 파일들의 목록을 보여주는 곳
	var uploadResult = $(".uploadResult ul");

	// 업로드 결과를 로드해서 보여줌
	// 매개변수로 들어가는 uploadResultArr은 controller에서 return해준 list이다
	function showUploadedFile(uploadResultArr) {
		 var str = "";
		 
		 // 일단 반복문인데 첨부파일 5개를 올렸으면 그 5개에 대해서
		 $(uploadResultArr).each(function(i, obj) {
			 // 첨부파일이 이미지가 아니면 if를 이미지면 esle를 실행
			 // 요약하면 ul의 li로 업로드한 각각의 첨부파일들을 보여주는데
			 // 이미지도 보여주고, 링크도 달아서 보여준다
			 // 이미지는 이미지 파일의 경우 저장된 섬네일을 보여주고 일반 파일의 경우 미리 지정된 attach.jpg란 이름으로 저장된 이미지를 보여준다
			 // 링크의 경우(a tag) 파일은 controller-download, 이미지는 확대해서 보여주게된다
			 if(!obj.image){
				 var fileCallPath=encodeURIComponent(obj.uploadPath+"/"+obj.uuid+"_"+obj.fileName);
				 
		           str += "<li><div><a href='/sample/download?fileName="+fileCallPath+"'>"+
		           "<img src='/resources/img/attach.jpg'>"+obj.fileName+"</a>"+
		           "<span data-file=\'"+fileCallPath+"\' data-type='file'> x </span>"+
		           "</div></li>";
			
			 }else{
				 var fileCallPath=encodeURIComponent(obj.uploadPath+"/s_"+obj.uuid+"_"+obj.fileName);
				 var originPath=obj.uploadPath+"\\"+obj.uuid+"_"+obj.fileName;
				 originPath=originPath.replace(new RegExp(/\\/g),"/");
				 
				 str += "<li><a href=\"javascript:showImage(\'"+originPath+"\')\">"+
				 // 위의 문장이 확대해서 보여주는 부분인데 javascript로 정의된 showImage 함수를 실행해라는 뜻
	              "<img src='display?fileName="+fileCallPath+"'></a>"+
	              "<span data-file=\'"+fileCallPath+"\' data-type='image'> x </span>"+
	              "<li>";
			 }
		 });
		 uploadResult.append(str);
		 // 5개의 파일을 업로드 했으니 ul에 담을 li는 총 다섯개가 있을 것이다
		 // 위의 for(each)에서 5개의 str을 uploadResult에 append해서 결과를 보여주게 된다
	 }
	
	var cloneObj=$(".uploadDiv").clone();
	// .clone은 선택한 요소를 복사한다
	
	$("#uploadBtn").on("click",function(){
		var formData=new FormData();
		// formData는 jsvaScript객체인데 데이터를 저장해 주는 기능을 한다? 아마도
				
		var inputFile=$("input[name='uploadFile']");
		
		var files=inputFile[0].files;
		// input tag가 한 개라서 저기 위에 있는 input에서 올린 파일들을 뜻한다
		// 무슨 말이냐면 uploadFile이라는 이름을 가진 input tag가 5개라면 
		// inputFile에는 5개의 input tag정보가 담긴다
		// 각각읠 inputFile[0~4]로 사용?할 수 있는데
		// 이 파일에서 위의 조건(uploadFile이라는 이름을 가진 input tag)을 만족하는 tag가 한 개라서
		// inputFile[0]이라고 칭하면 딱 하나인 그 tag를 뜻하게 된다
		console.log(files);
		// 업로드 할 파일을 출력
		
		for(var i=0; i<files.length; i++){
			// 파일 이름이(확장자) 잘못되었거나 사이즈가 안맞으면 업로드를 할 수 없다
			// 이 과정을 input tag로 보낸(업로드한) 모든 파일을 대상으로 검사한다 
			if (!checkExtension(files[i].name, files[i].size)) {
				return false;
			}
			formData.append("uploadFile",files[i]);
			// formdata에 업로드 할 수 있는 파일들을 추가한다
		}
		// 그리고 ajax로 controller - uploadAjaxAction로 보낸다
		$.ajax({
			url:"uploadAjaxAction",
			processData : false,
			contentType: false,
			data:formData,
			type:'POST',
			dataType:'json',
			success:function(result){
				// 성공하면 console에 결과를 띄워주고
				// showuploadfile함수(위에서 만듬)를 통해
				// 화면(ul의 li들)에 띄워준다
				console.log(result);
				showUploadedFile(result);
				$(".uploadDiv").html(cloneObj.html());
			}
		});
	});
});
</script>
</body>
</html>
