from PIL import Image
from numpy import *
from pylab import *
from copy import copy
import maxflow
import networkx as nx
from collections import deque


in1 = array(Image.open("input1.jpg"),'f')
out1 = array(Image.open("out1.jpg"),'f')
in2 = array(Image.open("input2.jpg"),'f')
out2 = array(Image.open("out2.jpg"),'f')


def nbrs(x,y , ImageShape):  # returns 8-neighbours of a pixel without going out of bounds 
    xmax = ImageShape[0]
    ymax = ImageShape[1]
    out = []
    for i in range(-1,2):
        for j in range(-1,2):
            if (-1<(x+i)<xmax) and (-1<(y+j)<ymax):
                out += [(x+i , y+j)]
    out.remove((x,y))
    return out
    

def cut_cost( node1 , node2 , img): # returns pairwise cost of cutting node1(location) from node2(location) based on their intensity in img
    Ix = img[node1]
    Iy = img[node2]
    return exp( - ((Ix-Iy)**2)/(2*SIGMA**2) )
    
    # Boykov implementation functions from here:


def tree_cap(p,q,G , tree): # returns remaining flow from p to q if p belongs to the source tree and from q to p if p belongs to sink tree
    # G is our graph
    try:
        if p=='s': #special case
            return G[p][q]['w']
        if p=='t': #special case
            return G[q][p]['w']
        if tree[p] == 's':
            return G[p][q]['w']
        elif tree[p] == 't':
            return G[q][p]['w']
        else:
            raise Exception("tree_cap: p doesn't belong to any tree")
    except KeyError: # there is no edge between p and q
        return 0

def origins(node,parent): # returns origins of a node by recursively looking in dictionary of parent
    while node in parent:
        node = parent[node]
    return node
            
        
# first image: assume pixels (153:188 , 166:277 ) are selected by the user as foreground region
#       also          pixels (29:104 , 53:189 ) are selected as background
SIGMA = 4 # factor affecting likelihood and smoothness 
ALPHA = 1 # factor weighting loglikelihood of pixels belonging to bg or fg( for unary term tunning)
BETA = 1 # factor weighting smoothness among pixels ( for pairwise term tunning)
img = in1
iMax , jMax = img.shape
fg_reg = slice(153,188) , slice( 166,277)
bg_reg = slice(29 , 104 ) , slice(53,188)
#def segmentGraph(img , fg_reg , bg_reg):  # performs graphcut segmentation on image based on foreground and background regions (used for likelihood calculation for unary term)
    # extract likelihood for unary term of cost:
# likelihood function will be based on intensity of each pixel, I will use exp(-(I - region_mean)^2/2sigma^2) for likelihoodness of pixel belonging to region (background or foreground) 
# The closer the intensity is to mean, the closer likelihood will be to 1 which is based on the assumption that each regions intensities are close to each other. 
# for assigning cost function though, we assign log likelihood of pixel for a region as a cost of assigning it to the other one. This In this manner, the closer pixel intensity is to a region's mean, there will be a higher cost for assigning it to the other one.
img = img / img.max() # normalize img
'''                         # likelihood assignment
fg_mean = img[fg_reg].mean()
bg_mean = img[bg_reg].mean()
#SIGMA = abs(fg_mean - bg_mean) /2 
fg_lh = exp( -((img-fg_mean)**2)/(2*SIGMA**2) )
bg_lh = exp( -((img-bg_mean)**2)/(2*SIGMA**2) )

   # Initialize (directed) Graph structure  , as mentioned in the paper
print "Initializing Graph...",
G = nx.DiGraph()
node_ids = [] # a list for names of nodes, each node corresponds to a pixel in image and its id is same as that pixel's position
for i in range(iMax):
    for j in range(jMax):
        node_ids.append((i,j))
        
G.add_nodes_from(node_ids)
G.add_nodes_from(['s' , 't']) # add foreground and background nodes ( equal as source and sink or 's' and 't')

for i in range(iMax):
    for j in range(jMax):
# now add edges , first add edges between each pixel and source and sink (from source to edge, and from edge to sink) nodes (these weights are cost functions corresponding to unary terms )
        G.add_edge('s',(i,j), w = -ALPHA*log(bg_lh[i,j]) )
        G.add_edge((i,j),'t' , w = -ALPHA*log(fg_lh[i,j]) )
# add edge between neighbour pixels( Using 4-neighbours here): I selected exp(-(Ix - Iy)^2/2sigma^2) cost function for pairwise term between pixels x and y ( Ix is intensity of pixel x)
        neighbs = nbrs(i,j , img.shape)
        for nbNode in neighbs:
            G.add_edge((i,j), nbNode , w = BETA*cut_cost((i,j) , nbNode , img) )
            
    # done with initialization , now perform Boykov min-cut/max-flow algorithm:

print "Done!\nPerforming Boykov min-cut/max-flow...",  
'''  
# sample graph for test:
gt = nx.DiGraph()
gt.add_nodes_from(['s','t',(1,2),(2,3)])
gt.add_edges_from([('s',(1,2),{'w':2}),('s',(2,3),{'w':9}),((1,2),'t',{'w':5}),((2,3),'t',{'w':4}),((1,2),(2,3),{'w':1}),((2,3),(1,2),{'w':2})])
#sample graph2 for testing the algorithm:
gt2 = nx.DiGraph()
gt2.add_nodes_from([ 's','t',(1,1),(1,2), (2,1),(3,1),(3,2),(4,1) ])
# gt2 is the graph at the end of class slides for Advanced Image Segmentation
gt2.add_edges_from([ ('s',(1,1),{'w':5}),('s',(1,2),{'w':9}),('s',(2,1),{'w':4}),
                   ((1,1),(3,1),{'w':2}),((1,1),(4,1),{'w':1}),((1,1),(2,1),{'w':3}),
                   ((1,2),(2,1),{'w':5}),((1,2),(3,2),{'w':3}),
                   ((2,1),(1,1),{'w':2}),((2,1),(4,1),{'w':6}),((2,1),(3,2),{'w':5}),((2,1),(1,2),{'w':2}),
                   ((3,1),'t',{'w':6}),((3,1),(4,1),{'w':2}),
                   ((3,2),(4,1),{'w':3}),((3,2),'t',{'w':5}),((3,2),(2,1),{'w':1}),
                   ((4,1),'t',{'w':8}) ])
# to test the graph cut algorithm it self on the sample graph , uncomment following line:  ( you can view visualization of sample graph on http://pmneila.github.io/PyMaxflow/tutorial.html )
#G = gt
G=gt2
#Boykov initialization:
A = deque(['s','t']) # que of active nodes ( will use queu as suggested by the paper
S = ['s'] # nodes belonging to source tree
T = ['t'] # nodes belonging to sink tree
Orphans = deque() # que of nodes that have become orphans
total_flow = 0.0 # keeps record of pushed flow which is equal to cost of the cut
has_origin = zeros_like(img,bool) # tracks whether nodes have origins or not ( their parents link to 's' or 't' )
dist_origin = ones_like(img,int)*1000 # tracks how many parents it takes a node to arrive at a source ( or sink )
        
tree = zeros_like(img , dtype = 'a1') # determines which tree ( 's' or 't' or '0' for free nodes ) each node belongs to
tree[:,:] = 0
parent = dict() # a dictionary that keeps track of { nodes:parents }

#Growth Stage:
def Grow(G):  # pops nodes from Active list (A) from left and grows the tree to which the popped node belongs until it reaches the other tree
              # returns path for Augement Stage
    while A:
        p = A[0]    
        tree_p = p if type(p) is str else tree[p]
        if tree_p=='s':
            insource = 1
        elif tree_p=='t':
            insource = 0
        else: # tree[p]=='0' p is a free node, why is it in active list?!
            raise Exception("Grow Stage: p is a free node")
        if insource:
            p_nbrs = G.successors_iter(p)
        else: # p belongs to the sink tree
            p_nbrs = G.predecessors_iter(p)
        for q in p_nbrs:
            tree_q = q if type(q) is str else tree[q]
            if tree_cap(p,q, G , tree):
                if tree_q == '0':
                    # claim the free node:
                    tree[q] = tree_p
                    parent.update({q:p})
                    has_origin[q] = 1
                    if p=='s' or p=='t':
                        dist_origin[q] = 1
                    else:
                        dist_origin[q] = dist_origin[p]+1
                    A.append(q) 
                elif tree_q != tree_p: # found a path!
                    #print "FOUND PATH"
                    # construct the path, the left most node should be source and right most will be sink
                    path = deque()
                    first = p if tree_p=='s' else q
                    second = q if tree_p=='s' else p
                    while first in parent:
                        path.appendleft(first)
                        first = parent[first]
                    if first!= 's':
                        raise Exception("Growth Path construction:didn't reach source")
                    path.appendleft(first)
                    while second in parent:
                        path.append(second)
                        second = parent[second]
                    if second != 't':
                        raise Exception("Growth Path construction:didn't reach sink")
                    path.append(second)
                    return path
        A.popleft()
    return None


def Augment(G,P):  # augments on path from grow stage, pusesh maximumm possible flows and results in orphans
    # find the bottleneck ( minimum possible flow)
    bottleneck = inf
    for i in range(len(P)-1):
        if G[P[i]][P[i+1]]['w'] < bottleneck:
            bottleneck = G[P[i]][P[i+1]]['w']
    # push flow equal to bottle neck and update resid graph
    for i in range(len(P)-1):
        G[P[i]][P[i+1]]['w'] -= bottleneck
        if G[P[i]][P[i+1]]['w'] == 0:
            G.remove_edge(P[i],P[i+1])
            tree_p = P[i] if type(P[i]) is str else tree[P[i]]
            tree_q = P[i+1] if type(P[i+1]) is str else tree[P[i+1]]
            if tree_p == tree_q == 's': 
                parent.pop(P[i+1])
                has_origin[P[i+1]] = 0
                Orphans.append(P[i+1])
                dist_origin[P[i+1]] = 1000
            if tree_p == tree_q == 't': 
                parent.pop(P[i])
                Orphans.append(P[i])
                has_origin[P[i]] = 0
                dist_origin[P[i]] = 1000
    return bottleneck
        


def Adoption(Orphans): # processes resulting Orphans from Augmentation stage
    while Orphans:
        p = Orphans.popleft()
        # proccess orphan:
        p_nbrs_list = nbrs(p[0],p[1] , img.shape) # neighbours list
        for q in p_nbrs_list:
            if tree[p]==tree[q] and tree_cap(q,p,G,tree) and has_origin[q]:
                orig = origins(q,parent)
                if orig=='s' or orig=='t':
                    parent.update({p:q})
                    has_origin[p] = 1
                    dist_origin[p] = dist_origin[q]+1
                else:
                    has_origin[q] = 0
        if not has_origin[p]: # means no parrent is found for p
            #search in neighbours for setting orphans and active nodes
            for q in p_nbrs_list:
                if tree[q]==tree[p] and tree_cap(q,p,G,tree):
                    if has_origin[q]:
                        A.append(q)
                    elif parent[q]==p:
                        parent.pop(q)
                        Orphans.append(q)
            #p becomes free node:
            tree[p] = '0'
            if p in A: A.remove(p)
    

while True:
    P = Grow(G)
    if P == None:
        break
    total_flow += Augment(G,P)
    Adoption(Orphans)
print "Done!\n check array 'tree' for segmentation results, total flow is: " , total_flow 
