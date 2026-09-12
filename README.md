## Problem Statement

Diabetic Retinopathy (DR) is a diabetes-related eye disease that can cause irreversible vision loss if it is not detected and treated at an early stage. Screening is particularly challenging in rural and underserved regions because of limited access to ophthalmologists, specialized equipment, and timely diagnosis.

Although automated fundus-image analysis can assist in DR screening, real-world retinal images often suffer from poor illumination, blur, low contrast, and incomplete fields of view. These factors can reduce the reliability of automated predictions. Furthermore, many existing deep-learning approaches function as black-box classifiers, providing limited clinical explanation for their decisions.

The proposed solution addresses these challenges through a MATLAB-based retinal image analysis pipeline that focuses on:

- Assessing fundus image quality before diagnosis
- Enhancing images affected by illumination and contrast issues
- Identifying clinically relevant retinal structures and lesions
- Grading diabetic retinopathy severity from fundus images
- Providing visual explanations for model predictions
- Supporting referral decisions through confidence-based screening
- Enabling an offline-first workflow suitable for resource-constrained settings

The objective is to develop a practical, explainable, and deployment-oriented screening system that can assist healthcare professionals in identifying patients who require further ophthalmic evaluation.
