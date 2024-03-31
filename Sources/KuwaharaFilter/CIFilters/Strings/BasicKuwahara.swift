//Created by Lugalu on 31/03/24.

import Foundation

package let BasicKuwahara: String = """
                kernel float4 Kuwahara(sampler s,int kernelSize) {
                    float2 uv = destCoord();
                    int radius = kernelSize / 2;
                    float window = 2.0 * float(radius) + 1;
                    int quad = int(ceil(window/2));
                    int ks = quad * quad;

                    float4 q1 = sampleQuadrant(s, uv, 0, radius, 0, radius, ks);
                    float4 q2 = sampleQuadrant(s, uv, -radius, 0, 0, radius, ks);
                    float4 q3 = sampleQuadrant(s, uv, -radius, 0, -radius, 0, ks);
                    float4 q4 = sampleQuadrant(s, uv, 0, radius, -radius, 0, ks);

                    float minValue = min(q1.a, min(q2.a, min(q3.a, q4.a)));
                
                    float4 q;
                    q.x = minValue == q1.a ? 1 : 0;
                    q.y = minValue == q2.a ? 1 : 0;
                    q.z = minValue == q3.a ? 1 : 0;
                    q.w = minValue == q4.a ? 1 : 0;
                
                    if (dot(q, vec4(1.0)) > 1) {
                        return premultiply(float4((q1.rgb + q2.rgb + q3.rgb + q4.rgb) / 4.0, 1.0));
                    }else {
                        return float4(q1.rgb * q.x + q2.rgb * q.y + q3.rgb * q.z + q4.rgb * q.w, 1.0);
                    }
                }
            """
