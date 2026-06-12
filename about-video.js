(function () {
  var videos = [
    "https://ik.imagekit.io/maxontorres/sanjiang-motovlog.mp4",
    "https://ik.imagekit.io/maxontorres/motovlog-feb-24.mp4",
  ];

  var video = document.querySelector(".about-video-background video");
  if (!video || videos.length === 0) return;

  var index = 0;

  function playCurrent() {
    video.src = videos[index];
    video.load();
    video.play().catch(function () {});
  }

  video.addEventListener("ended", function () {
    index = (index + 1) % videos.length;
    playCurrent();
  });

  playCurrent();
})();
