#!/bin/bash
echo "==================== Nodes ===================="
kubectl get nodes -o wide
for node in $(kubectl get nodes -o name); do
    echo "----- Describe $node -----"
    kubectl describe $node | tail -n 20
done

echo ""
echo "==================== Pods ===================="
kubectl get pods --all-namespaces -o wide
for pod in $(kubectl get pods --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $pod | cut -d'/' -f1)
    pname=$(echo $pod | cut -d'/' -f2)
    echo "----- Describe pod $pname in namespace $ns -----"
    kubectl describe pod $pname -n $ns | tail -n 20
    echo "----- Last logs for pod $pname -----"
    kubectl logs $pname -n $ns --tail=20
done

echo ""
echo "==================== Deployments ===================="
kubectl get deployments --all-namespaces -o wide
for deploy in $(kubectl get deployments --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $deploy | cut -d'/' -f1)
    dname=$(echo $deploy | cut -d'/' -f2)
    echo "----- Describe deployment $dname in namespace $ns -----"
    kubectl describe deployment $dname -n $ns | tail -n 20
    echo "----- Rollout status -----"
    kubectl rollout status deployment/$dname -n $ns
done

echo ""
echo "==================== ReplicaSets ===================="
kubectl get rs --all-namespaces -o wide
for rs in $(kubectl get rs --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $rs | cut -d'/' -f1)
    rsname=$(echo $rs | cut -d'/' -f2)
    echo "----- Describe replicaset $rsname in namespace $ns -----"
    kubectl describe rs $rsname -n $ns | tail -n 20
done

echo ""
echo "==================== Services ===================="
kubectl get svc --all-namespaces -o wide
for svc in $(kubectl get svc --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $svc | cut -d'/' -f1)
    svcname=$(echo $svc | cut -d'/' -f2)
    echo "----- Describe service $svcname in namespace $ns -----"
    kubectl describe svc $svcname -n $ns | tail -n 20
    echo "----- Endpoints -----"
    kubectl get endpoints $svcname -n $ns
done

echo ""
echo "==================== ConfigMaps ===================="
kubectl get cm --all-namespaces
for cm in $(kubectl get cm --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $cm | cut -d'/' -f1)
    cmname=$(echo $cm | cut -d'/' -f2)
    echo "----- Describe ConfigMap $cmname in namespace $ns -----"
    kubectl describe cm $cmname -n $ns | tail -n 20
done

echo ""
echo "==================== Secrets ===================="
kubectl get secrets --all-namespaces
for sec in $(kubectl get secrets --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $sec | cut -d'/' -f1)
    secname=$(echo $sec | cut -d'/' -f2)
    echo "----- Describe Secret $secname in namespace $ns -----"
    kubectl describe secret $secname -n $ns | tail -n 20
done

echo ""
echo "==================== Resource Quotas ===================="
kubectl get quota --all-namespaces
for quota in $(kubectl get quota --all-namespaces -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\n"}{end}'); do
    ns=$(echo $quota | cut -d'/' -f1)
    qname=$(echo $quota | cut -d'/' -f2)
    echo "----- Describe ResourceQuota $qname in namespace $ns -----"
    kubectl describe quota $qname -n $ns | tail -n 20
done

echo ""
echo "==================== Events ===================="
kubectl get events --all-namespaces --sort-by=.metadata.creationTimestamp | tail -n 50

echo ""
echo "==================== Done ===================="

