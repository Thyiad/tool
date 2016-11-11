function genCommercial(st) {

  var strList= [];
  var lines = st.split('\n');
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i].trim();
    if(line== ''){
      continue;
    }

    var dataList = line.split(' ');
    if(dataList.length!==3){
      console.log(`这个数据不对：在第${i}行`);
      continue;
    }
    var str= `{
      "type":"top-n-sales",
      "sku":"${dataList[2].trim()}",
      "groupID":"${dataList[0].trim()}",
      "sortIndex":${dataList[1].trim()}
    }`;

    strList.push(str);
  }

  return strList;

}
