/* =============================================================
   AutoHUB – Cart AJAX Operations
   Supports both authenticated and guest users.
   ============================================================= */

(function () {
  'use strict';

  /* ----- helpers ----- */
  function ctxPath() {
    return document.body.dataset.ctx || '';
  }

  function showToast(message, type) {
    let container = document.getElementById('toastContainer');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toastContainer';
      container.className = 'toast-container';
      document.body.appendChild(container);
    }
    const toast = document.createElement('div');
    toast.className = 'toast-msg' + (type === 'error' ? ' error' : '');
    toast.textContent = message;
    container.appendChild(toast);
    setTimeout(function() { toast.remove(); }, 3100);
  }

  function updateCartBadge(count) {
    const badge = document.getElementById('cartBadge');
    if (badge) {
      badge.textContent = count;
      badge.style.display = count > 0 ? 'inline-flex' : 'none';
    }
  }

  /* ----- AJAX helper ----- */
  function cartPost(params) {
    const form = new URLSearchParams(params);
    return fetch(ctxPath() + '/cart', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: form.toString()
    }).then(function (res) {
      return res.json();
    }).catch(function(err) {
      console.error('Cart AJAX error:', err);
      return { success: false, message: 'Errore di comunicazione con il server' };
    });
  }

  /* ----- Add to cart ----- */
  window.addToCart = function (productId, qty) {
    cartPost({ action: 'add', productId: productId, quantity: qty || 1 })
      .then(function (data) {
        if (data.success) {
          showToast('Aggiunto al carrello', 'success');
          updateCartBadge(data.cartCount);
        } else {
          showToast(data.message || 'Impossibile aggiungere il prodotto', 'error');
        }
      });
  };

  /* ----- Update qty ----- */
  function updateCartItem(productId, qty) {
    cartPost({ action: 'update', productId: productId, quantity: qty })
      .then(function (data) {
        if (data.success) {
          updateCartBadge(data.cartCount);
          const subEl = document.querySelector('[data-subtotal="' + productId + '"]');
          if (subEl) subEl.textContent = data.itemSubtotal;
          const totalEl = document.getElementById('cartGrandTotal');
          if (totalEl) totalEl.textContent = data.cartTotal;
          if (data.cartCount === 0) {
            showEmptyState();
          } else if (qty <= 0) {
            const row = document.querySelector('[data-cart-row="' + productId + '"]');
            if (row) row.remove();
          }
        } else {
          showToast(data.message || 'Errore durante l\'aggiornamento', 'error');
        }
      });
  }

  /* ----- Remove item ----- */
  function removeCartItem(productId) {
    cartPost({ action: 'remove', productId: productId })
      .then(function (data) {
        if (data.success) {
          const row = document.querySelector('[data-cart-row="' + productId + '"]');
          if (row) row.remove();
          updateCartBadge(data.cartCount);
          const totalEl = document.getElementById('cartGrandTotal');
          if (totalEl) totalEl.textContent = data.cartTotal;
          if (data.cartCount === 0) showEmptyState();
        } else {
          showToast(data.message || 'Errore durante la rimozione', 'error');
        }
      });
  }

  /* ----- Clear cart ----- */
  function clearCart() {
    cartPost({ action: 'clear' })
      .then(function (data) {
        if (data.success) {
          updateCartBadge(0);
          showEmptyState();
        } else {
          showToast(data.message || 'Errore durante lo svuotamento', 'error');
        }
      });
  }

  function showEmptyState() {
    const table = document.getElementById('cartTable');
    const empty = document.getElementById('cartEmpty');
    const actions = document.getElementById('cartActions');
    if (table) table.style.display = 'none';
    if (empty) empty.style.display = 'block';
    if (actions) actions.style.display = 'none';
  }

  /* ----- Event listeners on cart page ----- */
  document.addEventListener('DOMContentLoaded', function () {

    // Add to cart buttons (catalog / product detail)
    document.querySelectorAll('.btn-add-to-cart').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        const pid = parseInt(btn.dataset.productId, 10);
        const qtyInput = document.getElementById('productQty');
        const qty = qtyInput ? parseInt(qtyInput.value, 10) : 1;
        addToCart(pid, qty || 1);
      });
    });

    // Qty + button
    document.querySelectorAll('.btn-qty-plus').forEach(function (btn) {
      btn.addEventListener('click', function () {
        const pid = parseInt(btn.dataset.productId, 10);
        const input = document.querySelector('.qty-input[data-product-id="' + pid + '"]');
        if (input) {
          input.value = Math.max(1, parseInt(input.value, 10) + 1);
          updateCartItem(pid, parseInt(input.value, 10));
        }
      });
    });

    // Qty - button
    document.querySelectorAll('.btn-qty-minus').forEach(function (btn) {
      btn.addEventListener('click', function () {
        const pid = parseInt(btn.dataset.productId, 10);
        const input = document.querySelector('.qty-input[data-product-id="' + pid + '"]');
        if (input) {
          const newVal = Math.max(0, parseInt(input.value, 10) - 1);
          input.value = newVal;
          updateCartItem(pid, newVal);
        }
      });
    });

    // Qty input change
    document.querySelectorAll('.qty-input').forEach(function (input) {
      input.addEventListener('change', function () {
        const pid = parseInt(input.dataset.productId, 10);
        const qty = Math.max(0, parseInt(input.value, 10) || 0);
        input.value = qty;
        updateCartItem(pid, qty);
      });
    });

    // Remove buttons
    document.querySelectorAll('.btn-remove-item').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        removeCartItem(parseInt(btn.dataset.productId, 10));
      });
    });

    // Clear cart button
    const clearBtn = document.getElementById('btnClearCart');
    if (clearBtn) {
      clearBtn.addEventListener('click', function (e) {
        e.preventDefault();
        if (confirm('Svuotare tutto il carrello?')) clearCart();
      });
    }

    // Product detail qty controls
    const qtyPlusDetail = document.getElementById('qtyPlus');
    const qtyMinusDetail = document.getElementById('qtyMinus');
    const qtyInputDetail = document.getElementById('productQty');

    if (qtyPlusDetail && qtyInputDetail) {
      qtyPlusDetail.addEventListener('click', function () {
        qtyInputDetail.value = parseInt(qtyInputDetail.value, 10) + 1;
      });
    }
    if (qtyMinusDetail && qtyInputDetail) {
      qtyMinusDetail.addEventListener('click', function () {
        const v = parseInt(qtyInputDetail.value, 10);
        if (v > 1) qtyInputDetail.value = v - 1;
      });
    }
  });

})();
