// $.ajaxSetup({'complete':ensureTran})

function order(trans)
{
	if(Object.prototype.toString.call(trans) !== "[object Array]"){
		alert("请传入车次数组，例如：['T1','T2']");
		return;
	}

	if(!window.trans){
		window.trans=trans;
	}
	query();
}

function query()
{
	if(!window.$query_ticket){
		window.$query_ticket = $('#query_ticket');
	}
	
	if(!$query_ticket.hasClass('btn-disabled')){
		window.needEnsure = true;
		$query_ticket.click();
		setTimeout(ensureTran,150);
	}else{
		setTimeout(query, 100);
	}
}

function ensureTran(xhr){
	//console.log(xhr);
	//if(!window.needEnsure){
	//	return;
	//}
	var trList = document.querySelectorAll('#t-list>table>tbody>tr');
	
	var findedTrList = [].filter.call(trList,(function(tr, trIdx){
		return window.trans.some(function(tran, idx){
			if(tr.id.indexOf(tran)>=0){
				tr.dataset.idx=idx;
				// T、K固定抢硬卧
				if(tran.startsWith('T') || tran.startsWith('K')){
					var td = tr.querySelector('td:nth-child(7)');
					return td && (td.innerText!=="无" && td.innerText!=="--");
				}
				// G固定抢二等座
				else if(tran.startsWith('G')){
					var td = tr.querySelector('td:nth-child(4)');
					return td && (td.innerText!=="无" && td.innerText!=="--");
				}
			}
			
			return false;
		});
	}));
	findedTrList.sort(function(value1,value2){
		var idx1 = parseInt(value1.dataset.idx);
		var idx2 = parseInt(value2.dataset.idx);
		return idx1-idx2;
	});
	
	if(findedTrList.length>0){
		findedTrList[0].querySelector('td:last-child>a').click();
	}else{
		setTimeout(query, 100);
	}
	// window.needEnsure = false;
}

order(['T25','T81','T77'])