function map = load_map(filename, xy_res, z_res, margin)
% LOAD_MAP Load a map from disk.
%  MAP = LOAD_MAP(filename, xy_res, z_res, margin).  Creates an occupancy grid
%  map where a node is considered fill if it lies within 'margin' distance of
%  on abstacle.
fileID=fopen(filename,'r');
C = textscan(fileID,'%s %f %f %f %f %f %f %f %f %f');
if(isempty([C{1}]))
    map=[];
    return;
end
Xmin=C{2};
Ymin=C{3};
Zmin=C{4};
Xmax=C{5};
Ymax=C{6};
Zmax=C{7};
map.xy_res=xy_res;
map.z_res=z_res;
l_x= (Xmax(1)-Xmin(1))/xy_res;
l_y=(Ymax(1)-Ymin(1))/xy_res;
l_z=(Zmax(1)-Zmin(1))/z_res;

% for i=2:numel(Xmin)
%     Xmin(i)=Xmin(i)-margin;
%     Ymin(i)=Ymin(i)-margin;
%     Zmin(i)=Zmin(i)-margin;
%     Xmax(i)=Xmax(i)+margin;
%     Ymax(i)=Ymax(i)+margin;
%     Zmax(i)=Zmax(i)+margin;
% end
  Xmin(2:end)=Xmin(2:end)-margin;
  Ymin(2:end)=Ymin(2:end)-margin;
  Zmin(2:end)=Zmin(2:end)-margin;
  Xmax(2:end)=Xmax(2:end)+margin;
  Ymax(2:end)=Ymax(2:end)+margin;
  Zmax(2:end)=Zmax(2:end)+margin;

    
% for i=1:((l_x)+1)
%     x_nodes(i)=Xmin(1)+(i-1)*xy_res;
% end
% for i=1:((l_y)+1)
%     y_nodes(i)=Ymin(1)+(i-1)*xy_res;
% end
% for i=1:((l_z)+1)
%    z_nodes(i)=Zmin(1)+(i-1)*z_res;    
% end

x_nodes=Xmin(1)+((1:((l_x+1)))-1)*xy_res;
y_nodes=Ymin(1)+((1:((l_y+1)))-1)*xy_res;
z_nodes=Zmin(1)+((1:((l_z+1)))-1)*z_res;

map((l_x+1)*(l_y+1)*(l_z+1)).x_node=[];
map((l_x+1)*(l_y+1)*(l_z+1)).y_node=[];
map((l_x+1)*(l_y+1)*(l_z+1)).z_node=[];
map((l_x+1)*(l_y+1)*(l_z+1)).cond=[];

% for k=1:l_z
%     for j=1:l_y
%         for i=1:l_x
%             map(i+(j-1)*l_x+(k-1)*l_x*l_y).x_node=x_nodes(i);
%             map(i+(j-1)*l_x+(k-1)*l_x*l_y).y_node=y_nodes(j);
%             map(i+(j-1)*l_x+(k-1)*l_x*l_y).z_node=z_nodes(k);
%          
%         end
%     end
% end
MAP=combvec(x_nodes,y_nodes,z_nodes)';

c=num2cell(MAP(:,1));[map(:).x_node]=deal(c{:});
c=num2cell(MAP(:,2));[map(:).y_node]=deal(c{:});
c=num2cell(MAP(:,3));[map(:).z_node]=deal(c{:});
% 
% for k=1:l_z
%     for j=1:l_y
%         for i=1:l_x
%             A=eltono(map(i+(j-1)*l_x+(k-1)*l_x*l_y).x_node,map(i+(j-1)*l_x+(k-1)*l_x*l_y).y_node,...
%                 map(i+(j-1)*l_x+(k-1)*l_x*l_y).z_node,xy_res,z_res);
%             state=zeros(8,numel(Xmin)-1);
%             for o=2:numel(Xmin)
%                 for q=1:8
%                     
%                     if A(q,1)>= Xmin(o)&& A(q,1)<=Xmax(o) && A(q,2)>= Ymin(o)&& A(q,2) <= Ymax(o) && A(q,3)>=Zmin(o) && A(q,3)<=Zmax(o)
%                         state(q,o-1)=1;
%                     else
%                         state(q,o-1)=0;
%                     end
%                     
%                         
%                 end
%             end
%                 if state==zeros(8,(numel(Xmin)-1))
%                      map(i+(j-1)*l_x+(k-1)*l_x*l_y).cond=0;         
%                     else
%                          map(i+(j-1)*l_x+(k-1)*l_x*l_y).cond=1;
%                 end
%                 
%            
%         end
%     end
% end
for i=1:(l_x+1)*(l_y+1)*(l_z+1)
            A=eltono(map(i).x_node,map(i).y_node,map(i).z_node,xy_res,z_res);
            state=zeros(8,numel(Xmin)-1);
            for o=2:numel(Xmin)
                for q=1:8
                    
                    if A(q,1)>= Xmin(o)&& A(q,1)<=Xmax(o) && A(q,2)>= Ymin(o)&& A(q,2) <= Ymax(o) && A(q,3)>=Zmin(o) && A(q,3)<=Zmax(o)
                        state(q,o-1)=1;
                    else
                        state(q,o-1)=0;
                    end
                    
                        
                end
            end
                if state==zeros(8,(numel(Xmin)-1))
                     map(i).cond=0;         
                    else
                         map(i).cond=1;
                end
                
           
end

        
  



end
