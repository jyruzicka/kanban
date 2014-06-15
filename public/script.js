function actOnClass(cls,func) {
  Array.prototype.forEach.call(document.querySelectorAll("."+cls), func);
}

function hideInactive() {
  var hide = function(el){ el.style.display = "none" };
  actOnClass("deferred", hide);
  actOnClass("waiting-on", hide);
  actOnClass("hanging", hide);
  actOnClass("hideable", hide);

  var button = document.querySelector(".toggle-hanging");
  button.classList.remove("typcn-folder-delete");
  button.classList.add("typcn-folder-add");
  button.onclick = showInactive;
}

function showInactive() {
  var show = function(el){  el.style.display = "" };
  actOnClass("deferred", show);
  actOnClass("waiting-on", show);
  actOnClass("hanging", show);
  actOnClass("hideable", show);

  var button = document.querySelector(".toggle-hanging");
  button.classList.remove("typcn-folder-add");
  button.classList.add("typcn-folder-delete");
  button.onclick = hideInactive;
}

document.addEventListener("DOMContentLoaded", function(){
  var toggle = document.querySelector(".toggle-hanging");
  if (toggle) { toggle.onclick = hideInactive; }
})