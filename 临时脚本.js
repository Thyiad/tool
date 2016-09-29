Array.prototype.toYiiParams = function () {
  var out = '[\n';
  this.forEach(function (item) {
    out+='[\n';
    if (item['name']) {
      out+="'name' => '"+item['name']+"',\n"
    }
    if (item['type']) {
      out+="'type' => '"+item['type']+"',\n"
    }
    if (item['data']) {
      out+="'data' => '"+item['data']+"',\n"
    }
    if (item['label']) {
      out+="'label' => '"+item['label']+"',\n"
    }
    if (item['tip']) {
      out+="'tip' => '"+item['tip']+"',\n"
    }
    // required
    if (item['required']) {
      out+="'required' => true,\n"
    }
    // minlength
    if (item['minlength']) {
      out+="'minlength' => "+item['minlength']+",\n"
    }
    // maxlength
    if (item['maxlength']) {
      out+="'maxlength' => "+item['maxlength']+",\n"
    }
    out+='],\n';
  });
  out+=']\n';
  console.log(out);
};

result = [];
var upc='';
var service=[];
var txtArr = $('sourceArea').value.split('\n');
for (var i = 0; i < txtArr.length; i++) {
  var current = txtArr[i].trim();
  if(current === 'Service：'){
    continue;
  }
  var upcMatch = current.match(/^\d、\s*([A-z]+)\s*(：|:)\s*$/);
  if (upcMatch !== null) {
    if (upc !== '') {
      result.push({
        upc:upc,
        service:service,
      })
      service = [];
    }
    upc = upcMatch[1];
    continue;
  }
  service.push(current);
}
if (upc !== '') {
  result.push({
    upc:upc,
    service:service,
  })
  service = [];
}
var out = '';
  out+='[\n';
result.forEach(function(item){
  out+='[\n';

out+=("'optValue' => '"+item.upc+"',\n");
out+=("'optText' => Yii::t('app','"+item.upc+"'),\n");

out+="'services' => [\n";
item.service.forEach(function(ser){
    out+='[\n';
    out+=("'optValue' => '"+ser+"',\n");
    out+=("'optText' => Yii::t('app','"+ser+"'),\n");
    out+='],\n';
})
out+="],\n";
  out+='],\n';
})
  out+=']\n';
