window.addEventListener("load", function() {
	var val = "sam"
	function test () {
		return val
	}	
	console.log(test())
	var val = "tom"
	console.log(test())

	newcl = test.toString()
	console.log(eval(newcl))
})