/* =============================================================
   AutoHUB – Validazione form client-side (italiano)
   ============================================================= */

(function () {
  'use strict';

  function getField(id) { return document.getElementById(id); }

  function showError(fieldId, message) {
    var field = getField(fieldId);
    var errEl = getField(fieldId + '-error');
    if (field) field.classList.add('error-field');
    if (errEl) errEl.textContent = message;
    return false;
  }

  function clearError(fieldId) {
    var field = getField(fieldId);
    var errEl = getField(fieldId + '-error');
    if (field) field.classList.remove('error-field');
    if (errEl) errEl.textContent = '';
  }

  var PATTERNS = {
    username: /^[a-zA-Z0-9_]{3,30}$/,
    email:    /^[\w.+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$/,
    phone:    /^[+\d\s\-()\/.]{7,20}$/,
    postal:   /^[A-Z0-9\s\-]{3,10}$/i,
    cardNum:  /^\d{4}[\s\-]?\d{4}[\s\-]?\d{4}[\s\-]?\d{4}$/,
    expiry:   /^(0[1-9]|1[0-2])\/\d{2}$/,
    cvv:      /^\d{3,4}$/,
    price:    /^\d+(\.\d{1,2})?$/
  };

  function validateUsername(val) {
    if (!val) return 'Username obbligatorio.';
    if (!PATTERNS.username.test(val)) return 'Username: 3-30 caratteri, solo lettere, numeri e underscore.';
    return '';
  }

  function validateEmail(val) {
    if (!val) return 'Indirizzo email obbligatorio.';
    if (!PATTERNS.email.test(val)) return 'Inserisci un indirizzo email valido.';
    return '';
  }

  function validatePassword(val) {
    if (!val) return 'Password obbligatoria.';
    if (val.length < 8) return 'La password deve avere almeno 8 caratteri.';
    return '';
  }

  function validateRequired(val, label) {
    if (!val || val.trim() === '') return (label || 'Questo campo') + ' è obbligatorio.';
    return '';
  }

  function validatePhone(val) {
    if (!val) return '';
    if (!PATTERNS.phone.test(val)) return 'Inserisci un numero di telefono valido.';
    return '';
  }

  function validatePostal(val) {
    if (!val) return 'CAP obbligatorio.';
    if (!PATTERNS.postal.test(val)) return 'Inserisci un CAP valido.';
    return '';
  }

  function validatePrice(val) {
    if (!val) return 'Prezzo obbligatorio.';
    if (!PATTERNS.price.test(val) || parseFloat(val) <= 0) return 'Inserisci un prezzo valido (es. 1500.00).';
    return '';
  }

  function onFieldChange(id, validatorFn) {
    var el = getField(id);
    if (!el) return;
    el.addEventListener('change', function () {
      var err = validatorFn(el.value.trim());
      if (err) showError(id, err); else clearError(id);
    });
    el.addEventListener('blur', function () {
      var err = validatorFn(el.value.trim());
      if (err) showError(id, err); else clearError(id);
    });
  }

  function initRegisterForm() {
    var form = getField('registerForm');
    if (!form) return;

    onFieldChange('username', validateUsername);
    onFieldChange('email', validateEmail);
    onFieldChange('password', validatePassword);
    onFieldChange('fullName', function(v){ return validateRequired(v, 'Nome completo'); });
    onFieldChange('phone', validatePhone);

    function validateConfirmPwd(val) {
      var pwd = getField('password');
      if (!val) return 'Conferma la password.';
      if (pwd && val !== pwd.value) return 'Le password non coincidono.';
      return '';
    }
    onFieldChange('confirmPassword', validateConfirmPwd);

    form.addEventListener('submit', function (e) {
      var valid = true;
      var username = getField('username');
      var email = getField('email');
      var password = getField('password');
      var confirmPwd = getField('confirmPassword');
      var fullName = getField('fullName');
      var err;

      err = validateUsername(username ? username.value.trim() : '');
      if (err) { showError('username', err); valid = false; } else clearError('username');

      err = validateEmail(email ? email.value.trim() : '');
      if (err) { showError('email', err); valid = false; } else clearError('email');

      err = validatePassword(password ? password.value : '');
      if (err) { showError('password', err); valid = false; } else clearError('password');

      if (password && confirmPwd) {
        if (!confirmPwd.value) {
          showError('confirmPassword', 'Conferma la password.'); valid = false;
        } else if (confirmPwd.value !== password.value) {
          showError('confirmPassword', 'Le password non coincidono.'); valid = false;
        } else clearError('confirmPassword');
      }

      err = validateRequired(fullName ? fullName.value.trim() : '', 'Nome completo');
      if (err) { showError('fullName', err); valid = false; } else clearError('fullName');

      if (!valid) e.preventDefault();
    });
  }

  function initLoginForm() {
    var form = getField('loginForm');
    if (!form) return;

    onFieldChange('username', function(v){ return validateRequired(v, 'Username'); });
    onFieldChange('password', function(v){ return validateRequired(v, 'Password'); });

    form.addEventListener('submit', function (e) {
      var valid = true;
      var username = getField('username');
      var password = getField('password');

      var err = validateRequired(username ? username.value.trim() : '', 'Username');
      if (err) { showError('username', err); valid = false; } else clearError('username');

      err = validateRequired(password ? password.value : '', 'Password');
      if (err) { showError('password', err); valid = false; } else clearError('password');

      if (!valid) e.preventDefault();
    });
  }

function initCheckoutForm() {
    var form = getField('checkoutForm');
    if (!form) return;

    var requiredFields = [
      { id: 'shippingName',    label: 'Nome completo' },
      { id: 'shippingAddress', label: 'Indirizzo' },
      { id: 'shippingCity',    label: 'Città' },
      { id: 'shippingCountry', label: 'Paese' }
    ];

    requiredFields.forEach(function(f) {
      onFieldChange(f.id, function(v){ return validateRequired(v, f.label); });
    });

    onFieldChange('shippingPostal', validatePostal);

    var methodInputs = document.querySelectorAll('input[name="paymentMethod"]');
    var ccFields = getField('creditCardFields');

    function toggleCCFields() {
      var selected = document.querySelector('input[name="paymentMethod"]:checked');
      if (ccFields) {
        ccFields.style.display = (selected && selected.value === 'Credit Card') ? 'block' : 'none';
      }
    }

    methodInputs.forEach(function(input) {
      input.addEventListener('change', toggleCCFields);
    });
    toggleCCFields();

    onFieldChange('cardNumber', function(v) {
      var sel = document.querySelector('input[name="paymentMethod"]:checked');
      if (!sel || sel.value !== 'Credit Card') return '';
      if (!v) return 'Numero carta obbligatorio.';
      if (!PATTERNS.cardNum.test(v)) return 'Inserisci un numero di carta valido (16 cifre).';
      return '';
    });
    onFieldChange('cardExpiry', function(v) {
      var sel = document.querySelector('input[name="paymentMethod"]:checked');
      if (!sel || sel.value !== 'Credit Card') return '';
      if (!v) return 'Data scadenza obbligatoria (MM/AA).';
      if (!PATTERNS.expiry.test(v)) return 'Formato: MM/AA.';
      return '';
    });
    onFieldChange('cardCvv', function(v) {
      var sel = document.querySelector('input[name="paymentMethod"]:checked');
      if (!sel || sel.value !== 'Credit Card') return '';
      if (!v) return 'CVV obbligatorio.';
      if (!PATTERNS.cvv.test(v)) return 'CVV: 3 o 4 cifre.';
      return '';
    });

    form.addEventListener('submit', function (e) {
      var valid = true;

      requiredFields.forEach(function(f) {
        var el = getField(f.id);
        var err = validateRequired(el ? el.value.trim() : '', f.label);
        if (err) { showError(f.id, err); valid = false; } else clearError(f.id);
      });

      var postal = getField('shippingPostal');
      var pe = validatePostal(postal ? postal.value.trim() : '');
      if (pe) { showError('shippingPostal', pe); valid = false; } else clearError('shippingPostal');

      var sel = document.querySelector('input[name="paymentMethod"]:checked');
      if (!sel) {
        var pmErr = getField('paymentMethod-error');
        if (pmErr) pmErr.textContent = 'Seleziona un metodo di pagamento.';
        valid = false;
      } else if (sel.value === 'Credit Card') {
        var cn = getField('cardNumber');
        var exp = getField('cardExpiry');
        var cvv = getField('cardCvv');

        if (cn) {
          var cerr = PATTERNS.cardNum.test(cn.value.replace(/\s/g,'')) ? '' : 'Numero carta non valido.';
          if (!cn.value) cerr = 'Obbligatorio.';
          if (cerr) { showError('cardNumber', cerr); valid = false; } else clearError('cardNumber');
        }
        if (exp) {
          var eerr = PATTERNS.expiry.test(exp.value) ? '' : 'Scadenza non valida (MM/AA).';
          if (!exp.value) eerr = 'Obbligatorio.';
          if (eerr) { showError('cardExpiry', eerr); valid = false; } else clearError('cardExpiry');
        }
        if (cvv) {
          var verr = PATTERNS.cvv.test(cvv.value) ? '' : 'CVV non valido.';
          if (!cvv.value) verr = 'Obbligatorio.';
          if (verr) { showError('cardCvv', verr); valid = false; } else clearError('cardCvv');
        }
      }

      if (!valid) e.preventDefault();
    });
  }

  function initProductForm() {
    var form = getField('productForm');
    if (!form) return;

    onFieldChange('name', function(v){ return validateRequired(v, 'Nome prodotto'); });
    onFieldChange('price', validatePrice);
    onFieldChange('category', function(v){ return validateRequired(v, 'Categoria'); });

    form.addEventListener('submit', function (e) {
      var valid = true;
      var name = getField('name');
      var price = getField('price');
      var cat = getField('category');
      var productImages = getField('productImages');
      var existingImages = form.querySelector('input[name="existingImageUrls"]');
      var err;

      err = validateRequired(name ? name.value.trim() : '', 'Nome prodotto');
      if (err) { showError('name', err); valid = false; } else clearError('name');

      err = validatePrice(price ? price.value.trim() : '');
      if (err) { showError('price', err); valid = false; } else clearError('price');

      err = validateRequired(cat ? cat.value.trim() : '', 'Categoria');
      if (err) { showError('category', err); valid = false; } else clearError('category');

      var hasExistingImages = existingImages && existingImages.value.trim();
      var existingImageCount = countLocalProductImages(hasExistingImages ? existingImages.value : '');
      var selectedImages = productImages && productImages.files ? productImages.files.length : 0;
      if (selectedImages > 0 && selectedImages < 3) {
        showError('productImages', 'Carica almeno 3 immagini prodotto.');
        valid = false;
      } else if (!hasExistingImages && selectedImages === 0) {
        showError('productImages', 'Carica da 3 a 5 immagini prodotto.');
        valid = false;
      } else if (selectedImages === 0 && existingImageCount < 3) {
        showError('productImages', 'Carica almeno 3 immagini prodotto salvate sul server.');
        valid = false;
      } else if (selectedImages > 5) {
        showError('productImages', 'Puoi caricare al massimo 5 immagini.');
        valid = false;
      } else {
        clearError('productImages');
      }

      if (!valid) e.preventDefault();
    });
  }

  function countLocalProductImages(rawValue) {
    if (!rawValue) return 0;
    return rawValue
      .replace(/[\[\]"']/g, '')
      .split(',')
      .map(function(value) { return value.trim().replace(/\\/g, '/'); })
      .filter(function(value) {
        return value.indexOf('/images/products/') === 0 || value.indexOf('images/products/') === 0;
      }).length;
  }

  function initAdminLoginForm() {
    var form = getField('adminLoginForm');
    if (!form) return;

    onFieldChange('username', function(v){ return validateRequired(v, 'Username'); });
    onFieldChange('password', function(v){ return validateRequired(v, 'Password'); });

    form.addEventListener('submit', function (e) {
      var valid = true;
      var u = getField('username');
      var p = getField('password');

      var err = validateRequired(u ? u.value.trim() : '', 'Username');
      if (err) { showError('username', err); valid = false; } else clearError('username');
      err = validateRequired(p ? p.value : '', 'Password');
      if (err) { showError('password', err); valid = false; } else clearError('password');

      if (!valid) e.preventDefault();
    });
  }

  document.addEventListener('DOMContentLoaded', function () {
    initRegisterForm();
    initLoginForm();
    initCheckoutForm();
    initProductForm();
    initAdminLoginForm();
  });
   
})();
