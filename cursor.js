(function () {
  var finePointer = window.matchMedia("(pointer: fine) and (hover: hover)");
  var reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

  if (!finePointer.matches || reducedMotion.matches) {
    return;
  }

  var cursor = document.createElement("div");
  cursor.className = "cursor-accent";
  cursor.setAttribute("aria-hidden", "true");
  document.body.appendChild(cursor);

  var targetX = window.innerWidth / 2;
  var targetY = window.innerHeight / 2;
  var currentX = targetX;
  var currentY = targetY;
  var isVisible = false;
  var animationFrame = 0;

  function render() {
    currentX += (targetX - currentX) * 0.22;
    currentY += (targetY - currentY) * 0.22;
    cursor.style.transform =
      "translate3d(" + currentX + "px, " + currentY + "px, 0) translate(-50%, -50%)";
    animationFrame = window.requestAnimationFrame(render);
  }

  function setVisible(visible) {
    if (isVisible === visible) {
      return;
    }

    isVisible = visible;
    cursor.classList.toggle("is-visible", visible);
  }

  function isInteractiveElement(element) {
    return Boolean(
      element &&
        element.closest(
          'a, button, [role="button"], .photo-card, .text-link'
        )
    );
  }

  window.addEventListener(
    "pointermove",
    function (event) {
      targetX = event.clientX;
      targetY = event.clientY;
      setVisible(true);
      cursor.classList.toggle("is-interactive", isInteractiveElement(event.target));
    },
    { passive: true }
  );

  function addClickPulse(event) {
    var pulse = document.createElement("span");
    pulse.className = "cursor-click-pulse";
    pulse.setAttribute("aria-hidden", "true");
    pulse.style.left = event.clientX + "px";
    pulse.style.top = event.clientY + "px";
    document.body.appendChild(pulse);

    window.setTimeout(function () {
      pulse.remove();
    }, 520);
  }

  window.addEventListener(
    "pointerdown",
    function (event) {
      if (event.button !== 0) {
        return;
      }

      cursor.classList.add("is-pressed");
      addClickPulse(event);
    },
    { passive: true }
  );

  window.addEventListener(
    "pointerup",
    function () {
      cursor.classList.remove("is-pressed");
    },
    { passive: true }
  );

  window.addEventListener("pointercancel", function () {
    cursor.classList.remove("is-pressed");
  });

  window.addEventListener("pointerleave", function () {
    setVisible(false);
    cursor.classList.remove("is-interactive");
    cursor.classList.remove("is-pressed");
  });

  window.addEventListener("blur", function () {
    setVisible(false);
    cursor.classList.remove("is-interactive");
    cursor.classList.remove("is-pressed");
  });

  function handleReducedMotionChange(event) {
    if (event.matches) {
      window.cancelAnimationFrame(animationFrame);
      cursor.remove();
    }
  }

  if (reducedMotion.addEventListener) {
    reducedMotion.addEventListener("change", handleReducedMotionChange);
  } else if (reducedMotion.addListener) {
    reducedMotion.addListener(handleReducedMotionChange);
  }

  animationFrame = window.requestAnimationFrame(render);
})();
