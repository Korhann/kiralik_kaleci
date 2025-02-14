const { setGlobalOptions } = require('firebase-functions/v2');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');

admin.initializeApp();

// Set region & time zone
setGlobalOptions({ region: 'europe-west2' });  // London (closest stable region)

exports.resetAppointments = onSchedule(
  { schedule: 'every Monday 00:00', timeZone: 'Europe/Istanbul' },  // Runs at 00:00 Turkey time
  async () => {
    try {
      const usersRef = admin.firestore().collection('Users');
      const usersSnapshot = await usersRef.get();

      let batch = admin.firestore().batch();
      let batchCounter = 0;

      for (const userDoc of usersSnapshot.docs) {
        const userRef = userDoc.ref;
        const userData = userDoc.data();

        // Haftalık randevu durumu resetleme
        if (userData.sellerDetails && userData.sellerDetails.selectedHoursByDay) {
          let updatedHours = userData.sellerDetails.selectedHoursByDay;
          Object.keys(updatedHours).forEach((day) => {
            updatedHours[day] = updatedHours[day].map((hourSlot) => ({
              ...hourSlot,
              istaken: false,
            }));
          });

          batch.update(userRef, { 'sellerDetails.selectedHoursByDay': updatedHours });
          batchCounter++;
        }

        // Haftalık randevuları silme
        const appointmentBuyerRef = userRef.collection("appointmentbuyer");
        const appointmentSellerRef = userRef.collection("appointmentseller");

        const appointmentsBuyer = await appointmentBuyerRef.get();
        const appointmentsSeller = await appointmentSellerRef.get();

        appointmentsBuyer.forEach((doc) => {
          batch.delete(doc.ref);
          batchCounter++;
        });

        appointmentsSeller.forEach((doc) => {
          batch.delete(doc.ref);
          batchCounter++;
        });

        // Commit batch every 500 writes to avoid Firestore limits
        if (batchCounter >= 500) {
          await batch.commit();
          batch = admin.firestore().batch();
          batchCounter = 0;
        }
      }

      // Commit any remaining batch writes
      if (batchCounter > 0) {
        await batch.commit();
      }

      console.log('Appointments successfully reset and deleted!');
    } catch (error) {
      console.error('Error resetting appointments:', error);
    }
  }
);
