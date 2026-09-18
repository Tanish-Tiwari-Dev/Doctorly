/// Patient-facing copy and centralized strings for Doctorly / Disha V1.
abstract final class DoctorStrings {
  // Action Bar
  static const String call = 'Call';
  static const String whatsapp = 'WhatsApp';
  static const String directions = 'Directions';
  static const String callUnavailable = 'Phone number not available';
  static const String whatsappUnavailable = 'WhatsApp contact not available';
  static const String directionsUnavailable = 'Location address not available';

  // OPD Status
  static const String openNow = 'Open now';
  static const String closedToday = 'Closed today';
  static const String byAppointmentOnly = 'By appointment only';
  static const String callToConfirmOpd = 'Call to confirm OPD timing';
  static String opensAt(String time) => 'Opens at $time';

  // 24x7 Emergency Banner
  static const String emergency24x7Banner = '24x7 Emergency Services Available';
  static const String emergencySubtext =
      'Emergency neurotrauma and critical care support available around the clock.';

  // Facts Row Labels
  static const String experienceLabel = 'Experience';
  static const String opdStatusLabel = 'Today\'s OPD';
  static const String teleconsultLabel = 'Teleconsult';

  // Teleconsultation Tri-state
  static const String teleconsultAvailable = 'Available';
  static const String teleconsultNotAvailable = 'Not Available';
  static const String teleconsultContact = 'Contact Clinic';

  // Section Headers
  static const String professionalDetails = 'Professional Details';
  static const String opdSchedule = 'OPD Schedule';
  static const String expertise = 'Specialized Care';
  static const String languages = 'Languages Spoken';
  static const String location = 'Hospital & Location';
  static const String verificationDetails = 'Verification & Transparency';
  static const String howWeVerify = 'How we verify doctors';
  static const String reviews = 'Patient Reviews';

  // Professional Labels
  static const String hospital = 'Hospital / Clinic';
  static const String designation = 'Designation';
  static const String qualification = 'Qualification';
  static const String subSpecialty = 'Sub-Specialty';
  static const String districtCity = 'District / City';

  // OPD Labels
  static const String opdDays = 'Days';
  static const String opdHours = 'Hours';
  static const String byAppointmentBadge = 'By Appointment';

  // Verification & Explainer
  static const String registration = 'Registration';
  static const String council = 'Medical Council';
  static const String verifiedOn = 'Verified On';
  static const String primarySource = 'Official Profile / Source';
  static const String secondarySource = 'Secondary Verification Source';
  static const String verifiedStatus = 'Verified';
  static const String pendingStatus = 'Pending verification';
  static const String verifiedExplainerTitle = 'About Doctor Verification';
  static const String verifiedExplainerBody =
      'Doctors marked as "Verified" have had their medical council registration, qualification credentials, and primary affiliations cross-verified against official registries.\n\n"Pending verification" indicates that information is currently undergoing verification. We continuously audit directory listings to maintain high standards of patient trust.';

  // Medical Disclaimer
  static const String disclaimerTitle = 'Medical Directory Disclaimer';
  static const String disclaimerBody =
      'Disha is an informational healthcare directory designed to assist patients in discovering qualified medical specialists. This directory does not provide medical advice, diagnosis, or treatment recommendations, nor does it rank or endorse specific practitioners.\n\nIn case of a medical emergency, please proceed immediately to the nearest emergency hospital or dial 108.';

  // Category Discovery & Explainers
  static const String categorySectionTitle = 'What do you need help with?';
  static const String allCategories = 'All Categories';
  static const String categoryExplainerTitle = 'About This Specialty';
  static const String categoryWhatIsThis = 'What is this?';
  static const String categoryWhenNeeded = 'When would I need it?';

  // 8 Disha Patient-Facing Categories Copy
  static const String catTraumaTitle = 'Brain & Spine Trauma';
  static const String catTraumaDesc =
      'Emergency surgical care for severe head trauma, brain concussions, skull fractures, and acute spine injuries.';
  static const String catTraumaWhen =
      'Consult when experiencing head injury from accidents, sudden spinal trauma, loss of consciousness, or acute neurological deficits following trauma.';

  static const String catBrainTumorTitle = 'Brain Tumor';
  static const String catBrainTumorDesc =
      'Specialized evaluation and neurosurgical removal of benign or malignant tumors of the brain and surrounding tissues.';
  static const String catBrainTumorWhen =
      'Consult following persistent unexplained headaches, new-onset seizures, vision or speech changes, or an abnormal brain MRI/CT scan finding.';

  static const String catSpineTitle = 'Spine Care';
  static const String catSpineDesc =
      'Comprehensive surgical and minimally-invasive treatments for spinal disc herniations, cord compressions, and vertebral instability.';
  static const String catSpineWhen =
      'Consult for chronic debilitating back or neck pain, sciatica shooting down limbs, numbness, weakness in hands or legs, or walking difficulties.';

  static const String catStrokeTitle = 'Stroke & Neurovascular';
  static const String catStrokeDesc =
      'Urgent endovascular interventions and surgical management of brain aneurysms, vascular malformations (AVMs), and acute strokes.';
  static const String catStrokeWhen =
      'Emergency care for sudden facial droop, arm weakness, slurred speech, or immediate surgical evaluation of detected cerebral aneurysms.';

  static const String catSkullBaseTitle = 'Pituitary & Skull Base';
  static const String catSkullBaseDesc =
      'Advanced endoscopic and microsurgical procedures targeting complex tumors at the skull base and pituitary gland.';
  static const String catSkullBaseWhen =
      'Consult for hormonal imbalances linked to pituitary adenomas, progressive vision loss, double vision, or acoustic neuromas.';

  static const String catPediatricTitle = 'Pediatric Neurosurgery';
  static const String catPediatricDesc =
      'Dedicated neurosurgical management of congenital brain defects, hydrocephalus, craniosynostosis, and pediatric brain or spine conditions.';
  static const String catPediatricWhen =
      'Consult for infants or children with abnormal head enlargement, spinal birth defects (spina bifida), pediatric tumors, or persistent pediatric seizures.';

  static const String catFunctionalTitle = 'Functional Neurosurgery';
  static const String catFunctionalDesc =
      'Surgical therapies including Deep Brain Stimulation (DBS) and surgical resection for movement disorders, tremors, and intractable epilepsy.';
  static const String catFunctionalWhen =
      'Consult when advanced Parkinson\'s disease, essential tremors, or severe epilepsy are not adequately managed with conventional medications.';

  static const String catGeneralTitle = 'General Neurosurgery';
  static const String catGeneralDesc =
      'Broad neurological assessment and standard neurosurgical care covering diverse neurological symptoms, conditions, and general second opinions.';
  static const String catGeneralWhen =
      'Consult for initial neurological evaluation, recurring unexplained neurological symptoms, or guidance on neurosurgical care pathways.';

  /// Helper returning (title, whatIsThis, whenNeeded) for a given category slug.
  static ({String title, String whatIsThis, String whenNeeded}) getCategoryExplainer(String slug) {
    switch (slug) {
      case 'trauma':
        return (
          title: catTraumaTitle,
          whatIsThis: catTraumaDesc,
          whenNeeded: catTraumaWhen,
        );
      case 'brain_tumor':
        return (
          title: catBrainTumorTitle,
          whatIsThis: catBrainTumorDesc,
          whenNeeded: catBrainTumorWhen,
        );
      case 'spine':
        return (
          title: catSpineTitle,
          whatIsThis: catSpineDesc,
          whenNeeded: catSpineWhen,
        );
      case 'stroke_neurovascular':
        return (
          title: catStrokeTitle,
          whatIsThis: catStrokeDesc,
          whenNeeded: catStrokeWhen,
        );
      case 'skull_base':
        return (
          title: catSkullBaseTitle,
          whatIsThis: catSkullBaseDesc,
          whenNeeded: catSkullBaseWhen,
        );
      case 'pediatric':
        return (
          title: catPediatricTitle,
          whatIsThis: catPediatricDesc,
          whenNeeded: catPediatricWhen,
        );
      case 'functional':
        return (
          title: catFunctionalTitle,
          whatIsThis: catFunctionalDesc,
          whenNeeded: catFunctionalWhen,
        );
      case 'general':
      default:
        return (
          title: catGeneralTitle,
          whatIsThis: catGeneralDesc,
          whenNeeded: catGeneralWhen,
        );
    }
  }

  /// Helper for tri-state values ('yes', 'no', 'unknown').
  /// Returns [showText] for 'yes', [hideText] for 'no', and [fallbackText] for 'unknown'/null/empty.
  /// Never returns the literal word "Unknown".
  static String formatTriState(
    String? value, {
      required String showText,
      String? hideText,
      required String fallbackText,
    }) {
    if (value == null) return fallbackText;
    final clean = value.trim().toLowerCase();
    if (clean == 'yes' || clean == 'true') {
      return showText;
    }
    if (clean == 'no' || clean == 'false') {
      return hideText ?? '';
    }
    return fallbackText;
  }
}
