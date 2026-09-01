/* =============================================================
   AutoHUB – Catalog & Admin Utilities
   ============================================================= */

(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {

    /* ----- Catalog: auto-submit on filter change ----- */
    var categoryInputs = document.querySelectorAll('.filter-category-radio');
    categoryInputs.forEach(function (input) {
      input.addEventListener('change', function () {
        var form = document.getElementById('catalogFilterForm');
        if (form) form.submit();
      });
    });

    var sortSelect = document.getElementById('sortBy');
    if (sortSelect) {
      sortSelect.addEventListener('change', function () {
        var form = document.getElementById('catalogFilterForm');
        if (form) form.submit();
      });
    }

    /* ----- Catalog: keyword search debounce ----- */
    var keywordInput = document.getElementById('keywordInput');
    if (keywordInput) {
      var debounceTimer;
      keywordInput.addEventListener('keyup', function () {
        clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function () {
          var form = document.getElementById('catalogFilterForm');
          if (form) form.submit();
        }, 500);
      });
    }

    /* ----- Admin product list: client-side filter ----- */
    var adminSearchInput = document.getElementById('adminProductSearch');
    if (adminSearchInput) {
      adminSearchInput.addEventListener('keyup', function () {
        var query = adminSearchInput.value.toLowerCase();
        var rows = document.querySelectorAll('[data-product-row]');
        rows.forEach(function (row) {
          var name = (row.dataset.productName || '').toLowerCase();
          var cat  = (row.dataset.productCat  || '').toLowerCase();
          row.style.display = (name.includes(query) || cat.includes(query)) ? '' : 'none';
        });
      });
    }

    var adminCatFilter = document.getElementById('adminCatFilter');
    if (adminCatFilter) {
      adminCatFilter.addEventListener('change', function () {
        var cat = adminCatFilter.value.toLowerCase();
        var rows = document.querySelectorAll('[data-product-row]');
        rows.forEach(function (row) {
          var rowCat = (row.dataset.productCat || '').toLowerCase();
          row.style.display = (!cat || rowCat === cat) ? '' : 'none';
        });
      });
    }

    /* ----- Admin: image URL preview ----- */
    var imgUrlInput = document.getElementById('imageUrl');
    var imgPreview  = document.getElementById('imagePreview');
    if (imgUrlInput && imgPreview) {
      function updatePreview() {
        var url = imgUrlInput.value.trim();
        if (url) { imgPreview.src = url; imgPreview.style.display = 'block'; }
        else { imgPreview.style.display = 'none'; }
      }
      imgUrlInput.addEventListener('input', updatePreview);
      imgUrlInput.addEventListener('change', updatePreview);
      updatePreview();
    }

    /* ----- Admin orders: active filter badge display ----- */
    var filterForm = document.getElementById('adminOrderFilterForm');
    if (filterForm) {
      var resetBtn = document.getElementById('btnResetFilter');
      if (resetBtn) {
        resetBtn.addEventListener('click', function (e) {
          e.preventDefault();
          document.querySelectorAll('#adminOrderFilterForm input, #adminOrderFilterForm select').forEach(function(el) {
            el.value = '';
          });
          filterForm.submit();
        });
      }
    }

    /* ----- Payment method toggle (checkout) ----- */
    var methodInputs = document.querySelectorAll('input[name="paymentMethod"]');
    var ccFields = document.getElementById('creditCardFields');
    if (methodInputs.length && ccFields) {
      function toggleCC() {
        var sel = document.querySelector('input[name="paymentMethod"]:checked');
        ccFields.style.display = (sel && sel.value === 'Credit Card') ? 'block' : 'none';
      }
      methodInputs.forEach(function(i){ i.addEventListener('change', toggleCC); });
      toggleCC();
    }

    /* ----- Navbar active link ----- */
    var currentPath = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(function (link) {
      var href = link.getAttribute('href') || '';
      if (href && currentPath.endsWith(href.split('?')[0])) {
        link.classList.add('active');
      }
    });

  });

})();