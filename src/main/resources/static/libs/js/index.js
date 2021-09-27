let hidden = true;

document.getElementById("name").addEventListener("input", (event) => {
    if (!hidden) {
        hideElems(["req_sent", "req_recv", "req_failed", "server-says"])
        hidden = true;
    }
    document.getElementById("server-says").style.opacity = 0;
    document.getElementById("output").innerHTML = "";
})

function sendName() {

    document.getElementById("output").innerHTML = "";
    document.getElementById("output").className = "";
    document.getElementById("server-says").style.opacity = 0;
    let name = document.getElementById("name").value;
    hidden = false;
    showElem("req_sent");

    sendEchoRequest(name, (response) => {
        showElem("req_recv");
        showResponse(response.msg);
    }, (error) => {
        showElem("req_failed");
    })

}

function showResponse(message) {
    let el = document.getElementById("output");
    el.className = "";

    showElem("server-says");
    fadeIn("server-says")

    setTimeout(function(){

        el.innerHTML = message+" ";
        el.style.width = "fit-content";

        createDynamicKeyFrame(el.getBoundingClientRect().width);
        el.style.width = "";
        el.className = "anim-line output";
        el.style.animation = 'none';
        el.offsetHeight;
        el.style.animation = null;
    }, 500);

}

function createDynamicKeyFrame(width) {
    document.getElementById("dynamicKeyFrames").innerHTML = "";
    document.getElementById("dynamicKeyFrames").innerHTML = `
        @keyframes typewriter{
          from{ width: 0; }
          to{ width: ${width}px; }
        }
    `;
}

function showElem(id) {
    document.getElementById(id).style.display = "block";
}

function hideElems(ids) {
    for (id of ids)
        document.getElementById(id).style.display = "None";
}

function sendEchoRequest(name, success, error) {

        $.ajax({
            type: "GET",
            contentType: "application/json",
            url: "/echo",
            data: {
                "name": name
            },
            headers: {
                Accept : "application/json",
            },
            success: function (data, status) {
                success(data)
            },
            error: function (xhr, textStatus, error) {
                error(error)
            },
        });

}

function fadeIn(elementId) {
    let id = setInterval(() => {
        var elem = document.getElementById(elementId);
        opacity = Number(window.getComputedStyle(elem).getPropertyValue("opacity"));
        if (opacity < 1) {
            opacity = opacity + 0.01;
            elem.style.opacity = opacity
        } else {
            clearInterval(id);
        }
    }, 10)
}