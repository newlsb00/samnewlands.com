// Mobile navigation toggle
function initNavToggle() {
  var toggle = document.querySelector('.nav-toggle');
  var navList = document.querySelector('.nav-list');
  if (toggle && navList) {
    toggle.addEventListener('click', function() {
      navList.classList.toggle('is-open');
    });
  }
}

// Load latest papers on homepage
function loadLatestPapers(containerId, count) {
  var container = document.getElementById(containerId);
  if (!container) return;

  fetch('data/papers.json')
    .then(function(r) { return r.json(); })
    .then(function(papers) {
      papers.sort(function(a, b) { return b.sortYear - a.sortYear; });
      var latest = papers.slice(0, count || 5);

      var html = '<div class="latest-papers-list">';
      latest.forEach(function(p) {
        var href = p.pdf || p.url || '';
        var titleHtml = href
          ? '<a href="' + href + '" target="_blank">' + p.title + '</a>'
          : p.title;
        var venue = '<em>' + p.venue + '</em>';
        html += '<div class="latest-paper-item">' +
          '<div class="latest-paper-title">' + titleHtml + '</div>' +
          '<div class="latest-paper-venue">' + venue + ' (' + p.year + ')</div>' +
          '</div>';
      });
      html += '</div>';
      container.innerHTML = html;
    })
    .catch(function() {
      // Silently fail - static content is the fallback
    });
}

// Load all publications on publications page
function loadAllPublications(containerId) {
  var container = document.getElementById(containerId);
  if (!container) return;

  fetch('data/papers.json')
    .then(function(r) { return r.json(); })
    .then(function(papers) {
      papers.sort(function(a, b) { return b.sortYear - a.sortYear; });

      var html = '<div class="publication-list">';
      papers.forEach(function(p) {
        var href = p.pdf || p.url || '';
        var titleHtml = href
          ? '<a href="' + href + '" target="_blank">' + p.title + '</a>'
          : p.title;
        var venue = p.venueDetail
          ? '<em>' + p.venue + '</em>, ' + p.venueDetail
          : '<em>' + p.venue + '</em>';

        var metaHtml = '';
        if (p.pdf) {
          metaHtml += '<a href="' + p.pdf + '" class="btn-pdf" target="_blank">PDF</a>';
        }
        if (p.url) {
          metaHtml += '<a href="' + p.url + '" class="btn-link" target="_blank">View</a>';
        }
        if (p.award) {
          metaHtml += '<span class="award-badge">' + p.award + '</span>';
        }

        var abstractHtml = '';
        if (p.abstract) {
          abstractHtml = '<details class="publication-abstract">' +
            '<summary>Abstract</summary>' +
            '<div class="abstract-text"><p>' + p.abstract + '</p></div>' +
            '</details>';
        }

        html += '<article class="publication-entry">' +
          '<div class="publication-year">' + p.year + '</div>' +
          '<h3 class="publication-title">' + titleHtml + '</h3>' +
          '<div class="publication-venue">' + venue + '</div>' +
          '<div class="publication-meta">' + metaHtml + '</div>' +
          abstractHtml +
          '</article>';
      });
      html += '</div>';
      container.innerHTML = html;
    })
    .catch(function() {
      // Silently fail - static content is the fallback
    });
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
  initNavToggle();
  loadLatestPapers('latest-papers', 4);
  loadAllPublications('all-publications');
});
