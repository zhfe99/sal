/*
Original Code From:
Copyright (C) 2006 Pedro Felzenszwalb
Modifications (may have been made) Copyright (C) 2011,2012 
  Chenliang Xu, Jason Corso.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/

/*A simple normalized histogram template class*/

#ifndef HISTOGRAM_H
#define HISTOGRAM_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <math.h>

template <class TYPE>
class Histogram
{
protected:
	double mass;
	int numBins;
	TYPE* bins;
	TYPE min;
	TYPE max;
	// more transient values used in locating bins, etc...
	TYPE alpha;
	TYPE beta;
	
public:
	
	Histogram(int n, double min_, double max_)
	{
		mass=0;
		numBins = n;
		bins = (TYPE*)malloc(sizeof(TYPE)*n);
		memset(bins,0,sizeof(TYPE)*n);
		min = min_;
		max = max_;
		
		alpha = ((double)numBins) / (max-min);
		beta = 1.0 / alpha;
	}
	Histogram(Histogram& copy)
	{
		mass = copy.mass;
		numBins = copy.numBins;
		bins = (TYPE*)malloc(sizeof(TYPE)*numBins);
		memcpy(bins,copy.bins,sizeof(TYPE)*numBins);	
		min = copy.min;
		max = copy.max;
		alpha = copy.alpha;
		beta = copy.beta;
	}
	~Histogram()
	{
		if(bins) free(bins);
		bins=0x0;
	}
	
	inline void addSample(TYPE s)
	{
		addWeightedSample(s,1);
	}
	
	void addWeightedSample(TYPE s, double w)
	{
		int bin=-1;
		
		bin = computeBin(s);
		
		if (mass == 0.0)
		{
			bins[bin] = 1;
			mass = w;
		}
		else
		{
			double oldmass = mass;
			mass += w;
			for (int i=0;i<numBins;i++)
			{
				if (i==bin)
					bins[i] = (oldmass*bins[i] + w) / mass;
				else
					bins[i] = oldmass*bins[i] / mass;
				
			}
		}
	}
	
	
	void appendToFile(FILE* fp)
	{
		fprintf(fp,"%d\n",numBins);
		for(int i=0;i<numBins;i++)
			fprintf(fp,"%lf%s",(double)bins[i],(i==numBins-1)?"\n":" ");
	}
	
	
	
	/** compute and return the chi-squared distance between the two histograms
	 * d(x,y) = sum( (xi-yi)^2 / (xi+yi) ) / 2;
	 * If the xi+yi yields a bin with zero count, then I disregard this bin...
	 * @param H
	 * @return
	 */
	double chiSquared(Histogram& H)
	{
		double chi = 0.0;
		
		for (int i=0;i<numBins;i++)
		{
			double a = bins[i] + H.bins[i];
			if (a == 0.0)
				continue;
			double b = bins[i] - H.bins[i];
			
			chi += b*b / a;
		}
		return chi/2.0;
	}
	
	
	void clear()
	{
		mass=0;
		memset(bins,0,sizeof(TYPE)*numBins);
	}
	
	
	int computeBin(TYPE s)
	{
		int bin;
		if (s <= min)
			bin=0;
		else if (s >= max)
			bin=numBins-1;
		else
		{  // compute the bin
			bin = (int)(alpha * (s - min));
			if (bin >= numBins)
				bin=numBins-1;
		}
		return bin;
	}
	
	
	double entropy()
	{
		double entropy=0.0;
		for (int i=0;i<numBins;i++)
			entropy += (bins[i] == 0) ? 0 : bins[i]*log(bins[i]);
		return -1. * entropy;
	}
	
	
	void convertInternalToCDF()
	{
		for (int i=1;i<numBins;i++)
			bins[i] += bins[i-1];
	}
	
	double euclidean(Histogram& H)
	{
		double euc = 0.0;
		
		for (int i=0;i<numBins;i++)
		{
			euc += (bins[i] - H.bins[i]) * (bins[i] - H.bins[i]);
		}
		return sqrt(euc);
	}
	
	
	double getBinCenter(int b)
	{
		return min + beta*(double)b + (beta/2.);
	}

	double getBinLeft(int b)
	{
		return min + beta*(double)b;
	}

	double getBinRight(int b)
	{
		return min + beta*(double)(b+1);
	}

	double getBinMass(int i)
	{
		return bins[i]*mass;
	}

	double getBinWeight(int i)
	{
		return bins[i];
	}
	
	double getBinWeightMax()
	{
		double m=getBinWeight(0);
		for (int i=1;i<numBins;i++)
		{
			double mm = getBinWeight(i);
			m = (mm > m) ? mm : m ; 
		}
		return m;
	}

	double getBinWeightMax(int &bin)
	{
		double m=getBinWeight(0);
		bin=0;
		for (int i=1;i<numBins;i++)
		{
			double mm = getBinWeight(i);
			bin = (mm > m) ? i : bin ; 
			m = (mm > m) ? mm : m ; 
		}
		return m;
	}

	double getBinWeightSum()
	{
		double sum=0;
		for (int i=0;i<numBins;i++)
		{
			sum += getBinWeight(i);
		}
		return sum;
	}
	
	double getLikelihood(TYPE d)
	{
		return bins[computeBin(d)];
	}

	double getMass()
	{
		return mass;
	}

	double getMax()
	{
		return max;
	}
	
	double getMin()
	{
		return min;
	}

	int getNumberOfBins()
	{
		return numBins;
	}
	
	double intersect(Histogram& H)
	{
		double val=0.0;
		
		assert(numBins == H.numBins);
		
		for (int i=0;i<numBins;i++)
			val += (bins[i] < H.bins[i]) ? bins[i] : H.bins[i];
		
		return val;
	}
	
	
	/** compute the symmetric kl Difference (averaging the two assymetric) */
	double klDistance(Histogram& H)
	{
		return 0.5 * (klDivergence(H) + H.klDivergence(*this));
	}
	
	/** compute the one-way kldivergence from this to H */
	double klDivergence(Histogram& H)
	{
		double d=0;
		for (int i=0;i<numBins;i++)
		{
			if ((bins[i] != 0) && (H.bins[i] != 0))
			{
			   d += bins[i] * log(bins[i]/H.bins[i]);
			}
		}
		return d;
	}
	
	double l1distance(Histogram& H)
	{
		double d = 0.0;
		
		for (int i=0;i<numBins;i++)
		{
			d += abs(bins[i] - H.bins[i]);
		}
		return d;
	}
	
	void mergeHistogram(Histogram& H)
	{
		for (int i=0;i<numBins;i++)
			bins[i] = (bins[i] + H.bins[i])/2.0;
		mass += H.getMass();
	}
	
	// only works for the case that the initial histogram here is 0 mass
	// XXX needs to be extended
	void mergeWeightedHistogram(Histogram& H, double w)
	{
		for (int i=0;i<numBins;i++)
			bins[i] += H.bins[i]*w;
		mass += w;
	}
	
	void setAndNormalize(Histogram* H)
	{
		double sum=0;
		for (int i=0;i<numBins;i++)
			sum += H->bins[i];
		sum = 1.0/sum;
		for (int i=0;i<numBins;i++)
			bins[i] = sum*H->bins[i];
		mass = H->mass;
	}
	
};

#endif /*HISTOGRAM_H*/
