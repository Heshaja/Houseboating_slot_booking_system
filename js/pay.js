function openLock() {
    document.getElementById('lock1').classList.add('fa-unlock');
    document.getElementById('lock1').classList.remove('fa-lock');
}

function closeLock() {
    document.getElementById('lock1').classList.add('fa-lock');
    document.getElementById('lock1').classList.remove('fa-unlock');
}

function proceedToPayment(paymentMethod) {
    if (!paymentMethod) {
        console.log("No payment method selected.");
        return;
    }
    // Display the selected payment method
    alert(`You have selected ${paymentMethod} as your payment method.`);
    // Perform additional actions, such as enabling a payment button
}

