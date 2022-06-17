function X = lhsdesignbnd(n,p,lb,ub,isexp,varargin)
%LHSDESIGNBND Generate a NxP latin hypercube sample with bounds
%   constraints and optional exponential distribution.
%   X=LHSDESIGNBND(N,P,LB,UB,ISEXP) generates a latin hypercube sample X
%   containing N values on each of P variables.  For each column, if ISEXP
%   is FALSE the N values are randomly distributed with one from each
%   of N intervals, between LB and UB, of identical widths (UB-LB)/N, and
%   they are randomly permuted.  For columns with ISEXP=TRUE, the logarithm
%   of the intervals have identical widths.
%
%   X=LHSDESIGNBND(...,'PARAM1',val1,'PARAM2',val2,...) specifies parameter
%   name/value pairs to control the sample generation.  See LHSDESIGN for 
%   valid parameters.
%
%   Latin hypercube designs are useful when you need a sample that is
%   random but that is guaranteed to be relatively uniformly/exponentially
%   distributed over each dimension.
%
%   Example:  The following command generates a latin hypercube sample X
%             containing 100 values for each of 2 variables.  The first
%             variable is uniformly sampled between -10 and +10, the
%             second is exponentially sampled between 10^2 and 10^5 (ie.
%             the exponent is uniformly sampled between 2 and 5).
%
%      x = LHSDESIGNBND(100,2,[-10 1e2],[10 1e5],[false true]);
%      % Show samples are well distributed.
%      figure;
%      semilogy(x(:,1),x(:,2),'.');
%
%   See also LHSDESIGN, LHSDESIGNCON.
%   Release History:
%   2015-01-01
%   * initial release with lhsdesigncon
%     Copyright (c) 2014, Rik Blok (rik.blok@ubc.ca)
%     All rights reserved.
% 
%     Redistribution and use in source and binary forms, with or without
%     modification, are permitted provided that the following conditions are met:
% 
%     1. Redistributions of source code must retain the above copyright notice, this
%        list of conditions and the following disclaimer. 
%     2. Redistributions in binary form must reproduce the above copyright notice,
%        this list of conditions and the following disclaimer in the documentation
%        and/or other materials provided with the distribution.
% 
%     THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
%     ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
%     WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
%     DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
%     ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
%     (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
%     LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
%     ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
%     (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
%     SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
% 
%     The views and conclusions contained in the software and documentation are those
%     of the authors and should not be interpreted as representing official policies, 
%     either expressed or implied, of the FreeBSD Project.
% Defaults
if nargin < 5,  isexp = false(size(lb));   end
% Error traps.
if any(ub<lb)
    error('There exist some ub<lb.  Upper bound must always be greater than or equal to lower bound.'); 
end
if any(lb(isexp)<=0) 
    error('There exist some lb(isexp)<=0. Lower bound of exponential parameters must be strictly positive.'); 
end
% Carry out latin hypercube sampling with range (0,1) for each variable.
X=lhsdesign(n,p,varargin{:});
% Logarithm of exponentially distributed parameter bounds.
lb(isexp) = log(lb(isexp));
ub(isexp) = log(ub(isexp));
% Check if lb & ub needed to be transposed.
if size(lb,2)==1, lb = lb.'; end % transpose
if size(ub,2)==1, ub = ub.'; end % transpose
% Rescale samples to bounds.  
% Multiply each column of X by (ub-lb) and add lb.
X = bsxfun(@plus,bsxfun(@times,X,ub-lb),lb);
% Here is an alternative to do the same rescaling but ~3x slower.
% one = ones(n,1); X = one * lb + one * (ub - lb) .* X;
% Revert exponentially distributed parameters.
X(:,isexp) = exp(X(:,isexp));
end
