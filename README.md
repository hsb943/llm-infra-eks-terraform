# 1. vLLM-based OpenAI-Compatible Inference Server on Kubernetes (Qwen)

1.1 GPU-backed vLLM inference server for Qwen deployed on Kubernetes with persistent model storage and an OpenAI-compatible API.

---

# 2. Overview & Motivation

2.1 This project demonstrates how to deploy a **self-hosted large language model** using **vLLM** with an **OpenAI-compatible API**, running on **Kubernetes**.

2.2 The primary goal is to focus on:

   2.2.1 Inference reliability  
   2.2.2 GPU efficiency  
   2.2.3 Deployment correctness  

2.3 The system is designed to be:

   2.3.1 Reproducible  
   2.3.2 Infrastructure-aware  
   2.3.3 Model-agnostic at the serving layer  

2.4 The project is intentionally minimal, emphasizing **real execution over architectural slides**.

---

# 3. System Architecture

## 3.1 Architecture Layers

3.1.1 The system consists of the following layers:

   3.1.1.1 **Inference Engine** – vLLM OpenAI API server  
   3.1.1.2 **Model Layer** – Qwen Instruct checkpoints from HuggingFace  
   3.1.1.3 **Container Layer** – Docker image encapsulating runtime dependencies  
   3.1.1.4 **Orchestration Layer** – Kubernetes Deployment + Service  
   3.1.1.5 **Storage Layer** – PersistentVolumeClaim mounted at `/root/models-hf` for persistent model weight storage  

3.1.2 The API surface is compatible with OpenAI-style endpoints, enabling drop-in replacement for downstream consumers.

## 3.2 High-Level Flow

3.2.1 Client sends request to Kubernetes Service.  
3.2.2 Traffic is routed to the vLLM Pod.  
3.2.3 vLLM loads model weights from the persistent volume (or downloads once).  
3.2.4 GPU-backed inference is executed.  
3.2.5 OpenAI-compatible JSON response is returned.  

---

# 4. Repository Structure

4.1 Project directory layout:

```
vllm-qwen-kubernetes/
├── Dockerfile
├── server.py
├── README.md
└── k8s/
    ├── pvc-hf-cache.yaml
    ├── qwen-vllm-config.yaml
    ├── qwen-vllm-deploy.yaml
    └── qwen-vllm-svc.yaml
```

---

# 5. Proof of Execution

5.1 The system has been:

   5.1.1 Built locally using Docker  
   5.1.2 Deployed on a Kubernetes cluster  
   5.1.3 Verified via live API requests  

5.2 Model weights are successfully loaded and cached.

5.3 Inference requests return valid OpenAI-compatible responses.

5.4 No mock components are used. All manifests correspond to running workloads.

1. Port Forwarding
<img width="1003" height="199" alt="1" src="https://github.com/user-attachments/assets/1dacd0cf-e8c2-4516-8289-2696fb8cc714" />

2. Asking LLm what problem does k8 solve
<img width="1558" height="160" alt="2" src="https://github.com/user-attachments/assets/e7ca7b3c-c1da-4324-a3a7-e9bebfee0d59" />

3. Cluster Resources 
<img width="669" height="228" alt="3" src="https://github.com/user-attachments/assets/07cece29-50a4-4acc-8217-4b6909bbe6f5" />




---

# 6. Execution Environment

6.1 The Kubernetes cluster was created using **Minikube**.

6.2 Host Operating System:

   6.2.1 Windows

6.3 Hardware Constraints:

   6.3.1 Single GPU with 4GB VRAM  
   6.3.2 Local development machine (non-cloud environment)

6.4 Cluster Characteristics:

   6.4.1 Single-node Minikube cluster  
   6.4.2 GPU support enabled within Minikube  
   6.4.3 Model served under constrained VRAM conditions  

---

# 7. Kubernetes Deployment Details

## 7.1 Deployment Characteristics

7.1.1 Single-replica GPU-backed Pod.  
7.1.2 PersistentVolumeClaim mounted at `/root/models-hf`.  
7.1.3 Environment-driven configuration via ConfigMap.  
7.1.4 Explicit GPU resource requests to avoid overcommit.  

## 7.2 Service Exposure

7.2.1 Internal ClusterIP (default).  
7.2.2 Can be upgraded to NodePort or LoadBalancer without code changes.  

---

# 8. How to Run

## 8.1 Build Docker Image

8.1.1 Run:

```bash
docker build -t vllm-qwen:latest .
```

## 8.2 Deploy to Kubernetes

8.2.1 Create persistent storage:

```bash
kubectl apply -f k8s/pvc-hf-cache.yaml
```

8.2.2 Apply configuration:

```bash
kubectl apply -f k8s/qwen-vllm-config.yaml
```

8.2.3 Deploy inference server:

```bash
kubectl apply -f k8s/qwen-vllm-deploy.yaml
```

8.2.4 Expose service:

```bash
kubectl apply -f k8s/qwen-vllm-svc.yaml
```

## 8.3 Send Test Request

8.3.1 Execute:

```bash
curl http://<SERVICE_IP>:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "Qwen/Qwen2.5-0.5B-Instruct",
    "messages": [{"role": "user", "content": "Hello"}]
  }'
```

---

# 9. Design Decisions & Constraints

## 9.1 Why vLLM

9.1.1 Efficient KV-cache management.  
9.1.2 Better GPU memory utilization under constrained VRAM.  
9.1.3 Production-grade inference semantics.  
9.1.4 Native OpenAI-compatible API support.  

## 9.2 Persistent Model Storage

9.2.1 PersistentVolumeClaim used instead of container-layer caching.  
9.2.2 Custom mount path `/root/models-hf`.  
9.2.3 Prevents hidden container-layer cache behavior.  
9.2.4 Ensures deterministic storage control across Pod restarts.  
9.2.5 Reduces cold-start latency.  

## 9.3 Model-Agnostic Serving Layer

9.3.1 Model name injected via configuration.  
9.3.2 Weights can be swapped without rebuilding infrastructure.  
9.3.3 Serving layer remains unchanged when models change.  

## 9.4 Inference-Only Scope

9.4.1 Training intentionally excluded.  
9.4.2 Fine-tuning intentionally excluded.  
9.4.3 Runtime remains lean and deployment-focused.  

## 9.5 Single Replica by Design

9.5.1 Emphasizes correctness before scale.  
9.5.2 Horizontal scaling intentionally deferred.  
9.5.3 Architecture supports scaling without structural changes.  

---

# 10. Position in the Larger System

10.1 This repository represents the **infrastructure layer** of a larger, end-to-end LLM platform composed of multiple independent components.

10.2 The overall platform consists of:

   10.2.1 Infrastructure provisioning for hosting fine-tuned LLMs (this repository).  
   10.2.2 Fine-tuning base language models using parameter-efficient methods.  
   10.2.3 Deploying and serving fine-tuned models on this infrastructure.  
   10.2.4 Agent-based applications consuming these models instead of external APIs (e.g., OpenAI).  

10.3 This repository specifically represents the **serving layer**, which is the second part of the second project within the four-project architecture.

10.4 This repository intentionally focuses only on infrastructure concerns.

10.5 Model training, serving logic extensions, and agent orchestration are handled in separate repositories to maintain clear separation of responsibilities.

---

# 11. Notes

11.1 This project prioritizes:

   11.1.1 Correctness.  
   11.1.2 Reproducibility.  
   11.1.3 Real execution.  

11.2 All components in this repository:

   11.2.1 Are running.  
   11.2.2 Are validated.  
   11.2.3 Reflect actual deployment artifacts.  

11.3 Polish is intentionally secondary to clarity and system integrity.
