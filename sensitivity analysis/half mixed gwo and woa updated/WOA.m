%_________________________________________________________________________%
%  Whale Optimization Algorithm (WOA) source codes demo 1.0               %
%                                                                         %
%  Developed in MATLAB R2011b(7.13)                                       %
%                                                                         %
%  Author and programmer: Seyedali Mirjalili                              %
%                                                                         %
%         e-Mail: ali.mirjalili@gmail.com                                 %
%                 seyedali.mirjalili@griffithuni.edu.au                   %
%                                                                         %
%       Homepage: http://www.alimirjalili.com                             %
%                                                                         %
%   Main paper: S. Mirjalili, A. Lewis                                    %
%               The Whale Optimization Algorithm,                         %
%               Advances in Engineering Software , in press,              %
%               DOI: http://dx.doi.org/10.1016/j.advengsoft.2016.01.008   %
%                                                                         %
%_________________________________________________________________________%


% The Whale Optimization Algorithm
function [Leader_score,Leader_pos,Convergence_curve]=WOA(SearchAgents_no,Max_iter,lb,ub,dim,fobj,whale_z,wolf_z)
swap_mode = 1 ;
whale_gap = 1 + swap_mode ;
wolf_start = 1 + swap_mode;
wolf_gap =1 + swap_mode ;

%Initialize the positions of search agents
Positions= initialization(SearchAgents_no,dim,ub,lb);

% initialize position vector and score for the leader
Leader_pos=zeros(1,dim);
Leader_score=inf; %change this to -inf for maximization problems

%wolf initialization 
Alpha_pos=zeros(1,dim);
Alpha_score=inf; %change this to -inf for maximization problems

Beta_pos=zeros(1,dim);
Beta_score=inf; %change this to -inf for maximization problems

Delta_pos=zeros(1,dim);
Delta_score=inf; %change this to -inf for maximization problems



Convergence_curve=zeros(1,Max_iter);

t=0;% Loop counter
ll=0;
whale_itter = 0;
wolf_itter = 0;

% Main loop
while t<Max_iter 
   
    for i=1:whale_gap:size(Positions,1)
         
%         display("whale" + i )
        % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;
       
        % Calculate objective function for each search agent
        fitness=fobj((Positions(i,:)));
       
        %%
        % Update the leader
        if fitness<Leader_score % Change this to > for maximization problem
            Leader_score=fitness; % Update alpha
            Leader_pos=Positions(i,:);
        end
         
    end
  
    a=whale_z*(2-t*((2)/Max_iter)); % a decreases linearly fron 2 to 0 in Eq. (2.3)
    
    % a2 linearly dicreases from -1 to -2 to calculate t in Eq. (3.12)
    a2=-1+t*((-1)/Max_iter)*whale_z;
    
    % Update the Position of search agents 
    for i=1:whale_gap:size(Positions,1)
        
        r1=rand(); % r1 is a random number in [0,1]
        r2=rand(); % r2 is a random number in [0,1]
        
        A=2*a*r1-a;  % Eq. (2.3) in the paper
        C=2*r2;      % Eq. (2.4) in the paper
        
        
        b=1;               %  parameters in Eq. (2.5)
        l=(a2-1)*rand+1;   %  parameters in Eq. (2.5)
        
        p = rand();        % p in Eq. (2.6)
        
        for j=1:size(Positions,2)
            
            if p<0.5   
                if abs(A)>=1
                 
                    rand_leader_index = 2*randi( floor( (size(Positions,1)-1 )/2 ) ) +1;%floor(SearchAgents_no*rand()+1);
%                   Positions(5,:
                    X_rand = Positions(rand_leader_index, :);
                    D_X_rand=abs(C*X_rand(j)-Positions(i,j)); % Eq. (2.7)
                    Positions(i,j)=X_rand(j)-A*D_X_rand;      % Eq. (2.8)
                    
                elseif abs(A)<1
                    D_Leader=abs(C*Leader_pos(j)-Positions(i,j)); % Eq. (2.1)
                    Positions(i,j)=Leader_pos(j)-A*D_Leader;      % Eq. (2.2)
                end
                
            elseif p>=0.5
              
                distance2Leader=abs(Leader_pos(j)-Positions(i,j));
                % Eq. (2.5)
                Positions(i,j)=distance2Leader*exp(b.*l).*cos(l.*2*pi)+Leader_pos(j);
                
            end
            
        end
        Positions = round(Positions);
    end
    
    
   % [t Leader_score]
   
%    display( " whale positions " + Positions)

leader_whale_score = Leader_score;
leader_whale_pos =    Leader_pos;
% %% gray wolf
  
   
   for i=wolf_start:wolf_gap:size(Positions,1)  
%          display("wolf" + i ) 
       % Return back the search agents that go beyond the boundaries of the search space
        Flag4ub=Positions(i,:)>ub;
        Flag4lb=Positions(i,:)<lb;
        Positions(i,:)=(Positions(i,:).*(~(Flag4ub+Flag4lb)))+ub.*Flag4ub+lb.*Flag4lb;               
        
        % Calculate objective function for each search agent
        fitness=fobj((Positions(i,:)));
        
        % Update Alpha, Beta, and Delta
        if fitness<Alpha_score 
            Alpha_score=fitness; % Update alpha
            Alpha_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness<Beta_score 
            Beta_score=fitness; % Update beta
            Beta_pos=Positions(i,:);
        end
        
        if fitness>Alpha_score && fitness>Beta_score && fitness<Delta_score 
            Delta_score=fitness; % Update delta
            Delta_pos=Positions(i,:);%,Positions(i,:);
        end
   end
    
  
    a=(2-ll*((2)/Max_iter))*wolf_z; % a decreases linearly fron 2 to 0
    
    % Update the Position of search agents including omegas
    for i=wolf_start:wolf_gap:size(Positions,1)
        for j=wolf_start:size(Positions,2)     
                       
            r1=rand(); % r1 is a random number in [0,1]
            r2=rand(); % r2 is a random number in [0,1]
            
            A1=2*a*r1-a; % Equation (3.3)
            C1=2*r2; % Equation (3.4)
            
            D_alpha=abs(C1*Alpha_pos(j)-Positions(i,j)); % Equation (3.5)-part 1
            X1=Alpha_pos(j)-A1*D_alpha; % Equation (3.6)-part 1
                       
            r1=rand();
            r2=rand();
            
            A2=2*a*r1-a; % Equation (3.3)
            C2=2*r2; % Equation (3.4)
            
            D_beta=abs(C2*Beta_pos(j)-Positions(i,j)); % Equation (3.5)-part 2
            X2=Beta_pos(j)-A2*D_beta; % Equation (3.6)-part 2       
            
            r1=rand();
            r2=rand(); 
            
            A3=2*a*r1-a; % Equation (3.3)
            C3=2*r2; % Equation (3.4)
            
            D_delta=abs(C3*Delta_pos(j)-Positions(i,j)); % Equation (3.5)-part 3
            X3=(Delta_pos(j)-A3*D_delta); % Equation (3.5)-part 3             
            
            Positions(i,j)= round((X1+X2+X3)/3);% Equation (3.7)
       
%             display( " wolf positions " + Positions)
        end
              
    end
    
% % % % % %     if swap_mode ~= 0 
% % % % % %         for i=1:2:size(Positions,1)-1 
% % % % % %            tmp = Positions (i,:);
% % % % % %             Positions (i,:) = Positions (i+1,:);
% % % % % %             Positions (i+1,:) =  tmp;
% % % % % %         end
% % % % % %     end
% display(" wolf = " +Alpha_score + " whale = " +Leader_score + " dim = " + size(Positions,1)); 
  
      if(Leader_score > Alpha_score)
       Leader_score = Alpha_score;
       Leader_pos = Alpha_pos;
      end
      
      if(Leader_score < Alpha_score)
        Alpha_score = Leader_score ;
       Alpha_pos= Leader_pos ;
      end



 t=t+1;
 ll=ll+1;
    Convergence_curve(t)=min(Leader_score,Alpha_score);
end



